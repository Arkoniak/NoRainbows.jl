# import Pkg.Operations: print_diff, print_status
# using Pkg.Operations: is_instantiated, stat_rep, diff_array, is_package_downloaded, is_tracking_registry
# using Pkg: Types
# using Pkg: PackageSpec, Types.EnvCache, Types.is_stdlib, Types.Context

# @Base.kwdef struct PkgColorMap
#     add::Color = Color()
#     rm::Color = Color()
#     upgrade::Color = Color()
#     downgrade::Color = Color()
#     same::Color = Color()
#     uuid::Color = Color()
#     brackets::Color = Color()
# end
# const PKG_COLORS = Ref(PkgColorMap())
# function set_pkg_colors(;
#     default = nothing,
#     add = nothing,
#     rm = nothing,
#     upgrade = nothing,
#     downgrade = nothing,
#     same = nothing,
#     uuid = nothing,
#     brackets = nothing
# )
#     c = PKG_COLORS[]
#     PKG_COLORS[] = PkgColorMap(;
#         add = Color(coal(add, default, c.add)),
#         rm = Color(coal(rm, default, c.rm)),
#         upgrade = Color(coal(upgrade, default, c.upgrade)),
#         downgrade = Color(coal(downgrade, default, c.downgrade)),
#         same = Color(coal(same, default, c.same)),
#         uuid = Color(coal(uuid, default, c.uuid)),
#         brackets = Color(coal(brackets, default, c.brackets))
#     )

#     nothing
# end

# # utils.jl

# stdlib_dir() = normpath(joinpath(Sys.BINDIR::String, "..", "share", "julia", "stdlib", "v$(VERSION.major).$(VERSION.minor)"))

# function pathrepr(path::String)
#     # print stdlib paths as @stdlib/Name
#     if startswith(path, stdlib_dir())
#         path = "@stdlib/" * basename(path)
#     end
#     return "`" * Base.contractuser(path) * "`"
# end

# printpkgstyle(ctx::Context, cmd::Symbol, text::String, ignore_indent::Bool=false; color=:green) = printpkgstyle(ctx.io, cmd, text, ignore_indent; color = color)
# function printpkgstyle(io::IO, cmd::Symbol, text::String, ignore_indent::Bool=false; color=:green)
#     indent = textwidth(string(:Precompiling)) # "Precompiling" is the longest operation
#     ignore_indent && (indent = 0)
#     printstyled(io, lpad(string(cmd), indent), color=color, bold=true)
#     println(io, " ", text)
# end

# print_diff(ctx::Context, old, new) = print_diff(ctx.io, old, new)
# function print_diff(io::IO, old, new)
#     if !is_instantiated(old) && is_instantiated(new)
#         printstyled(io, PKG_COLORS[].add, "+ $(stat_rep(new))")
#     elseif !is_instantiated(new)
#         printstyled(io, PKG_COLORS[].rm, "- $(stat_rep(old))")
#     elseif is_tracking_registry(old) && is_tracking_registry(new) &&
#            new.version isa VersionNumber && old.version isa VersionNumber && new.version != old.version
#         if new.version > old.version
#             printstyled(io, PKG_COLORS[].upgrade, "↑ $(stat_rep(old)) ⇒ $(stat_rep(new; name=false))")
#         else
#             printstyled(io, PKG_COLORS[].downgrade, "↓ $(stat_rep(old)) ⇒ $(stat_rep(new; name=false))")
#         end
#     else
#         printstyled(io, PKG_COLORS[].same, "~ $(stat_rep(old)) ⇒ $(stat_rep(new; name=false))")
#     end
# end

# function print_status(env::EnvCache, old_env::Union{Nothing,EnvCache}, header::Symbol,
#                       uuids::Vector, names::Vector; manifest=true, diff=false, ignore_indent=false, io)
#     not_installed_indicator = sprint((io, args) -> printstyled(io, args...; color=:red), "→", context=io)
#     filter = !isempty(uuids) || !isempty(names)
#     # setup
#     xs = diff_array(old_env, env; manifest=manifest)
#     # filter and return early if possible
#     if isempty(xs) && !diff
#         printpkgstyle(io, header, "$(pathrepr(manifest ? env.manifest_file : env.project_file)) (empty " *
#                       (manifest ? "manifest" : "project") * ")", ignore_indent)
#         return nothing
#     end
#     xs = !diff ? xs : eltype(xs)[(id, old, new) for (id, old, new) in xs if old != new]
#     if isempty(xs)
#         printpkgstyle(io, Symbol("No Changes"), "to $(pathrepr(manifest ? env.manifest_file : env.project_file))", ignore_indent)
#         return nothing
#     end
#     xs = !filter ? xs : eltype(xs)[(id, old, new) for (id, old, new) in xs if (id in uuids || something(new, old).name in names)]
#     if isempty(xs)
#         printpkgstyle(io, Symbol("No Matches"),
#                       "in $(diff ? "diff for " : "")$(pathrepr(manifest ? env.manifest_file : env.project_file))", ignore_indent)
#         return nothing
#     end
#     # main print
#     printpkgstyle(io, header, pathrepr(manifest ? env.manifest_file : env.project_file), ignore_indent)
#     # Sort stdlibs and _jlls towards the end in status output
#     xs = sort!(xs, by = (x -> (is_stdlib(x[1]), endswith(something(x[3], x[2]).name, "_jll"), something(x[3], x[2]).name, x[1])))
#     all_packages_downloaded = true
#     for (uuid, old, new) in xs
#         if Types.is_project_uuid(env, uuid)
#             continue
#         end
#         pkg_downloaded = !is_instantiated(new) || is_package_downloaded(env.project_file, new)
#         all_packages_downloaded &= pkg_downloaded
#         print(io, pkg_downloaded ? " " : not_installed_indicator)
#         printstyled(io, PKG_COLORS[].brackets, " [")
#         printstyled(io, PKG_COLORS[].uuid, string(uuid)[1:8])
#         printstyled(io, PKG_COLORS[].brackets, "] ")
#         diff ? print_diff(io, old, new) : print_single(io, new)
#         println(io)
#     end
#     if !all_packages_downloaded
#         printpkgstyle(io, :Info, "packages marked with $not_installed_indicator not downloaded, use `instantiate` to download", ignore_indent)
#     end
#     return nothing
# end

# function print_status(ctx::Context, old_ctx::Union{Nothing,Context}, header::Symbol,
#                       uuids::Vector, names::Vector; manifest=true, diff=false, ignore_indent=false)
#     not_installed_indicator = sprint((io, args) -> printstyled(io, args...; color=:red), "→", context=ctx.io)
#     ctx.io = something(ctx.status_io, ctx.io) # for instrumenting tests
#     filter = !isempty(uuids) || !isempty(names)
#     # setup
#     xs = diff_array(old_ctx, ctx; manifest=manifest)
#     # filter and return early if possible
#     if isempty(xs) && !diff
#         printpkgstyle(ctx, header, "$(pathrepr(manifest ? ctx.env.manifest_file : ctx.env.project_file)) (empty " *
#                       (manifest ? "manifest" : "project") * ")", ignore_indent)
#         return nothing
#     end
#     xs = !diff ? xs : eltype(xs)[(id, old, new) for (id, old, new) in xs if old != new]
#     if isempty(xs)
#         printpkgstyle(ctx, Symbol("No Changes"), "to $(pathrepr(manifest ? ctx.env.manifest_file : ctx.env.project_file))", ignore_indent)
#         return nothing
#     end
#     xs = !filter ? xs : eltype(xs)[(id, old, new) for (id, old, new) in xs if (id in uuids || something(new, old).name in names)]
#     if isempty(xs)
#         printpkgstyle(ctx, Symbol("No Matches"),
#                       "in $(diff ? "diff for " : "")$(pathrepr(manifest ? ctx.env.manifest_file : ctx.env.project_file))", ignore_indent)
#         return nothing
#     end
#     # main print
#     printpkgstyle(ctx, header, pathrepr(manifest ? ctx.env.manifest_file : ctx.env.project_file), ignore_indent)
#     # Sort stdlibs and _jlls towards the end in status output
#     xs = sort!(xs, by = (x -> (is_stdlib(x[1]), endswith(something(x[3], x[2]).name, "_jll"), something(x[3], x[2]).name, x[1])))
#     all_packages_downloaded = true
#     for (uuid, old, new) in xs
#         if Types.is_project_uuid(ctx, uuid)
#             continue
#         end
#         pkg_downloaded = !is_instantiated(new) || is_package_downloaded(ctx, new)
#         all_packages_downloaded &= pkg_downloaded
#         print(ctx.io, pkg_downloaded ? " " : not_installed_indicator)
#         printstyled(io, PKG_COLORS[].brackets, " [")
#         printstyled(io, PKG_COLORS[].uuid, string(uuid)[1:8])
#         printstyled(io, PKG_COLORS[].brackets, "] ")
#         diff ? print_diff(ctx, old, new) : print_single(ctx, new)
#         println(ctx.io)
#     end
#     if !all_packages_downloaded
#         printpkgstyle(ctx, :Info, "packages marked with $not_installed_indicator not downloaded, use `instantiate` to download", ignore_indent)
#     end
#     return nothing
# end
