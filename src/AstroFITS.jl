"""
    AstroFITS

Julia package for reading and writing FITS (Flexible Image Transport System) files via the
CFITSIO library. It provides:

- [`FitsFile`](@ref) for opening, creating, and iterating over FITS files.
- [`FitsImageHDU`](@ref) and [`FitsTableHDU`](@ref) for image and table extensions.
- [`readfits`](@ref), [`readfits!`](@ref), [`writefits`](@ref), [`writefits!`](@ref) for
  high-level I/O.
- Re-exports of [`FitsCard`](@ref), [`FitsKey`](@ref), [`FitsHeader`](@ref), and related
  types and constants from the `FITSHeaders` package.

"""
module AstroFITS

export
    # Re-exports from `FITSHeaders`.
    @Fits_str,
    FitsKey,
    FitsCard,
    FitsCardType,
    FitsHeader,
    FITS_LOGICAL,
    FITS_INTEGER,
    FITS_FLOAT,
    FITS_STRING,
    FITS_COMPLEX,
    FITS_COMMENT,
    FITS_UNDEFINED,
    FITS_END,
    is_structural,

    # FITS header data units.
    FitsHDU,
    FitsHDUType,
    FitsImageHDU,
    FitsTableHDU,
    FITS_ANY_HDU,
    FITS_ASCII_TABLE_HDU,
    FITS_BINARY_TABLE_HDU,
    FITS_IMAGE_HDU,

    # FITS exception, etc.
    FitsError,
    FitsLogic,

    # FITS file.
    FitsFile,
    readfits,
    readfits!,
    openfits,
    writefits,
    writefits!

using TypeUtils
using TypeUtils: @public

@public(
    Header,
    OutputCstring,
    TableData,
    cfitsio_errmsg)

using FITSHeaders
using FITSHeaders:
    CardComment,
    CardName,
    CardPair,
    CardValue,
    FitsComplex,
    FitsFloat,
    FitsInteger,
    Undefined,
    is_comment,
    is_end,
    is_naxis,
    is_structural

using CEnum
using Base: @propagate_inbounds, string_index_err
using Base.Order: Ordering, Forward, Reverse
import Base: open, read, read!, write

if !isdefined(Base, :Memory)
    const Memory{T} = Vector{T}
end

include("CFITSIO.jl")
include("types.jl")
include("utils.jl")
include("files.jl")
include("hdus.jl")
include("images.jl")
include("tables.jl")
include("init.jl")

end # module
