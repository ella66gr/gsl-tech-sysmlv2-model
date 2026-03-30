import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [
		tailwindcss(),
		sveltekit()
	],
	ssr: {
		// 3d-force-graph and its deps are browser-only — bundle them for SSR
		// rather than trying to resolve as Node externals
		noExternal: ['3d-force-graph', 'three', 'three-spritetext', 'three-forcegraph', 'd3-force-3d'],
	},
});
