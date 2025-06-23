cd rust
set base_dir $PWD

for project in */
    cd $base_dir/$project
    echo "[CARGO] Build $(path basename $project)"
    env RUSTFLAGS='-C target-cpu=native' cargo build --release || continue
    set project_name (cargo metadata --no-deps --format-version 1 | jq --raw-output '.packages[0].name')
    ln -nf target/release/$project_name ~/.local/bin/$project_name
end
