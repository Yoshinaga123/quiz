import commonjs from '@rollup/plugin-commonjs'
import resolve from '@rollup/plugin-node-resolve'
import typescript from '@rollup/plugin-typescript'
import filesize from 'rollup-plugin-filesize'

/** @type {import('rollup').RollupOptions} */
export default {
  input: './scratch/input.ts',
  output: {
    file: './scratch/out_rollup.js',
    format: 'esm',
  },
  plugins: [
    resolve(),
    commonjs(),
    typescript({ tsconfig: './scratch/tsconfig.json', noEmit: false, declaration: false }),
    filesize(),
  ],
  treeshake: {
    preset: 'smallest',
    annotations: true,
  },
}
