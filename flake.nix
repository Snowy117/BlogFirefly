{
  description = "BlogFirefly";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
            corepack
            patchelf
            typst
          ];

          shellHook = ''
            # NixOS 无法直接运行 npm 包里预编译的 workerd（generic Linux 动态链接程序）。
            # 复制一份到 .direnv 下，替换解释器与 rpath，再让 Miniflare 使用它。
            workerd_src="$(ls -t node_modules/.pnpm/@cloudflare+workerd-linux-64@*/node_modules/@cloudflare/workerd-linux-64/bin/workerd 2>/dev/null | head -n1)"
            if [ -n "$workerd_src" ] && [ -f "$workerd_src" ]; then
              workerd_dir="$PWD/.direnv/workerd"
              mkdir -p "$workerd_dir"
              if [ ! -x "$workerd_dir/workerd" ] || [ "$workerd_src" -nt "$workerd_dir/workerd" ]; then
                cp -f "$workerd_src" "$workerd_dir/workerd"
                chmod +x "$workerd_dir/workerd"
                ${pkgs.patchelf}/bin/patchelf \
                  --set-interpreter "${pkgs.glibc}/lib/ld-linux-x86-64.so.2" \
                  --set-rpath "${pkgs.lib.makeLibraryPath [ pkgs.glibc ]}" \
                  "$workerd_dir/workerd"
              fi
              export MINIFLARE_WORKERD_PATH="$workerd_dir/workerd"
            fi
          '';
        };
      });
    };
}
