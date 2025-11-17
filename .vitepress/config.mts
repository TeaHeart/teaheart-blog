import { defineConfig } from 'vitepress'
import type { DefaultTheme } from 'vitepress/theme'
import fs from 'fs'
import path from 'path'

const webBaseDir = '/teaheart-blog/'
const srcBaseDir = './src'

// 读取文件
function readFileFromBaseDir(filename: string): string {
  const targetDir = path.join(process.cwd(), srcBaseDir, filename)

  if (!fs.existsSync(targetDir)) {
    return filename
  }

  return fs.readFileSync(targetDir, 'utf-8')
}

// 动态生成侧边栏的函数
function generateSidebarItem(dir: string): DefaultTheme.SidebarItem[] {
  const targetDir = path.join(process.cwd(), srcBaseDir, dir)

  if (!fs.existsSync(targetDir)) {
    return []
  }

  const items: DefaultTheme.SidebarItem[] = []

  const files = fs.readdirSync(targetDir)
  const mdFiles = files.filter((file) => file.endsWith('.md')).sort()

  for (const file of mdFiles) {
    const fileName = path.parse(file).name
    const filePath = path.join(dir, fileName).replace(/\\/g, '/')
    items.push({ text: fileName, link: filePath })
  }

  return items
}

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: '知心循际',
  description: '知心循际的个人博客',
  srcDir: srcBaseDir,
  base: webBaseDir,
  ignoreDeadLinks: true,
  head: [['link', { rel: 'icon', href: `${webBaseDir}favicon.ico` }]],

  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: '/logo.png',
    search: {
      provider: 'local',
    },

    nav: [
      { text: '主页', link: '/' },
      { text: '笔记', link: '/note/index' },
    ],

    sidebar: {
      '/note/default': generateSidebarItem('note/default'),
      '/note/big-data': generateSidebarItem('note/big-data'),
      '/note/java': generateSidebarItem('note/java'),
      '/note/mysql': generateSidebarItem('note/mysql'),
      '/note/seeyon': generateSidebarItem('note/seeyon'),
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/TeaHeart' },
      { icon: 'gitee', link: 'https://gitee.com/TeaHeart02' },
      {
        icon: { svg: readFileFromBaseDir(`/public/leetcode.svg`) },
        link: 'https://leetcode.cn/u/teaheart',
      },
    ],
  },
})
