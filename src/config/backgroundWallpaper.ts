import type { BackgroundWallpaperConfig } from "@/types/config";

export const backgroundWallpaper: BackgroundWallpaperConfig = {
	// 壁纸模式："banner" 横幅壁纸，"overlay" 全屏透明，"none" 纯色背景无壁纸
	mode: "banner",
	// 是否允许用户通过导航栏切换壁纸模式，设为false可提升性能（只渲染当前模式）
	switchable: true,

	// 背景图片配置
	src: {
		// 桌面背景图片
		desktop: "/assets/images/d1.png",
		// 移动背景图片
		mobile: "assets/images/MobileWallpaper/m1.avif",
	},

	// Banner模式特有配置
	banner: {
		// 图片位置
		// 支持所有CSS object-position值，如: 'top', 'center', 'bottom', 'left top', 'right bottom', '25% 75%', '10px 20px'..
		// 如果不知道怎么配置百分百之类的配置，推荐直接使用：'center'居中，'top'顶部居中，'bottom' 底部居中，'left'左侧居中，'right'右侧居中
		position: "0% 20%",

		homeText: {
			// 主页显示自定义文本（全局开关）
			enable: true,
			// 是否允许用户通过控制面板切换横幅标题显示
			switchable: true,
			// 主页横幅主标题
			title: "雪纷飞的博客",
			// 主页横幅副标题
			subtitle: [
				"五月降霜，六月飞雪",
				"风起，云涌，雷动",
				"愿你我皆能在风雪中前行",
			],
			typewriter: {
				//打字机开启 → 循环显示所有副标题
				//打字机关闭 → 每次刷新随机显示一条副标题
				enable: false, // 启用副标题打字机效果
				speed: 100, // 打字速度（毫秒）
				deleteSpeed: 50, // 删除速度（毫秒）
				pauseTime: 2000, // 完全显示后的暂停时间（毫秒）
			},
		},
		credit: {
			enable: {
				desktop: true, // 桌面端显示横幅图片来源文本
				mobile: true, // 移动端显示横幅图片来源文本
			},
			text: {
				desktop: "Bilibili - 龙族", // 桌面端要显示的来源文本
				mobile: "Pixiv - KiraraShss", // 移动端要显示的来源文本
			},
			url: {
				desktop: "https://www.bilibili.com/video/BV1ziWneGEpx/", // 桌面端原始艺术品或艺术家页面的 URL 链接
				mobile: "https://www.pixiv.net/users/42715864", // 移动端原始艺术品或艺术家页面的 URL 链接
			},
		},
		navbar: {
			// 横幅导航栏透明模式："semi" 半透明，"full" 完全透明，"semifull" 动态透明
			transparentMode: "semifull",
			// 是否开启毛玻璃模糊效果，开启可能会影响页面性能，如果不开启则是半透明，请根据自己的喜好开启
			enableBlur: true,
			// 毛玻璃模糊度
			blur: 3,
		},
		// 水波纹动画效果配置，开启会影响页面性能，请根据自己的喜好开启
		waves: {
			enable: {
				desktop: true, // 桌面端启用波浪动画效果
				mobile: true, // 移动端启用波浪动画效果
			},
			switchable: true,
		},
	},

	// 全屏透明覆盖模式特有配置
	overlay: {
		// 是否允许用户通过控制面板调整全屏透明模式参数
		switchable: {
			opacity: true,
			blur: true,
			cardOpacity: true,
		},
		// 层级，确保壁纸在背景层
		zIndex: -1,
		// 壁纸透明度
		opacity: 0.8,
		// 背景模糊度
		blur: 3,
		// 卡片透明度，0-1之间，值越小越透明
		cardOpacity: 0.6,
	},
}