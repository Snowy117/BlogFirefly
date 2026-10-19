import type { AnnouncementConfig } from "../types/announcementConfig";

export const announcementConfig: AnnouncementConfig = {
	// 公告标题
	title: "公告",
	// 公告内容
	content: "在写博客的时候，我是不会使用AI生成或润色的文字内容哒！",
	// 是否允许用户关闭公告
	closable: true,
	link: {
		enable: false, // 启用链接
		text: "了解更多", // 链接文本
		url: "/about/", // 链接 URL
		external: false, // 内部链接
	},
};
