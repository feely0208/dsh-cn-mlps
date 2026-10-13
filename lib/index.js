import { createPlugin, pkgRootFrom } from '@deepwhale-cn/dsh-guard-core/plugin';

export const { name, inject, apply } = createPlugin({
  name: 'cn-mlps',
  pkgRoot: pkgRootFrom(import.meta.url),
  skillFile: 'skill/cn-mlps.md',
  binFile: 'bin/cli.mjs',
  description: '按 GB/T 22239-2019 逐项对照代码与配置里可静态发现的等保项',
  whenToUse: 'TODO：写清什么时候该用（用户会说的话也列上）',
});
