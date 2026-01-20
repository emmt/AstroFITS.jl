# Aliases used for sub-indexing.
const IndexRange = OrdinalRange{<:Integer,<:Integer}
const SubArrayIndex = Union{Colon,Integer,IndexRange}
const SubArrayIndices{N} = NTuple{N,SubArrayIndex}

# Alias for specifying array size. C functions directly take vectors of integers (if of
# the correct type) and tuples of integers (if passed by reference).
const DimsLike = Union{Tuple{Vararg{Integer}},AbstractVector{<:Integer}}

if !isdefined(Base, :Memory)
    const Memory{T} = Vector{T}
end

# Structure used to pass a buffer as an output `Cstring` argument.
struct OutputCstring{T<:DenseVector{UInt8}}
    parent::T
end

"""
    AstroFITS.Header

Union of acceptable type(s) to specify a FITS header in `AstroFITS` package.

A header may be a vector of pairs like `key => val`, `key => (val,com)`, or `key => com`
with `key` the keyword name, `val` its value, and `com` its comment. The keyword name `key`
is a string or a symbol which is automatically converted to uppercase letters and trailing
spaces discarded. The syntax `key => com`, with `com` a string, is only allowed for
commentary keywords `COMMENT` or `HISTORY`. For other keywords, the value is mandatory but
the comment is optional, not specifying the comment is like specifying `nothing` for the
comment; otherwise, the comment must be a string. The value `val` may be `missing` or
`undef` to indicate that it is undefined. If the comment is too long, it is automatically
split across multiple records for commentary keywords and it is truncated for other
keywords. A non-commentary keyword may have units specified in square brackets at the
beginning of the associated comment. Commentary keywords may appear more than once, other
keywords are unique.

For example:

    ["VERIFIED" => true,
     "COUNT" => (42, "Fundamental number"),
     "SPEED" => (2.1, "[km/s] Speed of gizmo"),
     "USER" => "Julia",
     "AGE" => (undef, "Some undefined value."),
     "JOB" => (missing, "Another undefined value."),
     "HISTORY" => "Some historical information.",
     "COMMENT" => "Some comment.",
     "COMMENT" => "Some other comment.",
     "HISTORY" => "Some other historical information."]

defines a possible FITS header with several records: a keyword `VERIFIED` having a logical
value and no comments, a keyword `COUNT` having an integer value and a comment, a keyword
`SPEED` having a floating-point value and a comment with units, a keyword `USER` having a
string value, keywords `AGE` and `JOB` having comments but undefined values, and a few
additional commentary keywords.

A header may also be specified as a named tuple with entries `key = val`, `key = (val,com)`,
or `key = com`. The same rules apply as above except that `key` must be allowed as a
variable symbolic name (no embedded hyphen `'-'`).

Finally, most methods assume that `nothing` can be used to indicate an empty header.

!!! note
    Specifying a FITS header as a dictionary is purposely not implemented because, to a
    certain extend, the order of keywords in a FITS header is relevant and because some
    keywords (`COMMENT`, `HISTORY`, and `CONTINUE`) may appear more than once.

"""
const Header = Union{
    # Collections of FITS cards:
    FitsHeader, Tuple{Vararg{FitsCard}}, AbstractVector{FitsCard},
    # Collection of pairs:
    NamedTuple, Tuple{Vararg{CardPair}}, AbstractVector{<:CardPair}}

"""
    AstroFITS.OptionalHeader

Union of `Nothing` and of acceptable type(s) to specify a FITS header in `AstroFITS` package.

"""
const OptionalHeader = Union{Nothing,Header}

"""
    AstroFITS.ImageData{T,N}

Alias of the acceptable type(s) for the data of a `N`-dimensional FITS Image extension with
elements of type `T`.

"""
const ImageData{T<:Number,N} = AbstractArray{T,N}

"""
    AstroFITS.ColumnName

Union of acceptable types for the name of a column in a FITS Table extension.

"""
const ColumnName = Union{AbstractString,Symbol}

"""
    AstroFITS.ColumnIdent

Union of acceptable types for identifying a single column in a FITS Table extension.

"""
const ColumnIdent = Union{ColumnName,Integer}

"""
    AstroFITS.Columns

Union of acceptable types to specify several columns in a FITS Table extension.

The method:

    AstroFITS.columns_to_read(hdu::FitsTableHDU, cols::Columns)

yields an iterable object over the column indices to read in table.

"""
const Columns = Union{Colon,
                      OrdinalRange{<:Integer,<:Integer},
                      AbstractVector{<:ColumnIdent},
                      # If specified as a tuple, don't mix indices and names:
                      Tuple{Vararg{Integer}},
                      Tuple{Vararg{ColumnName}}}

"""
    AstroFITS.Rows

Union of possible types to specify one or several rows in a FITS Table extension.

The following methods are provided:

    AstroFITS.rows_to_read(hdu::FitsTableHDU, rows::Rows)
    AstroFITS.first_row_to_read(hdu::FitsTableHDU, rows::Rows)
    AstroFITS.last_row_to_read(hdu::FitsTableHDU, rows::Rows)

to yield a iterable object over the row indices to read in table and the first/last such row
indices.

"""
const Rows = Union{Colon,Integer,AbstractUnitRange{<:Integer}}

"""
    AstroFITS.ColumnData{T,N}

Alias for the possible type(s) of the cells of a `N`-dimensional column with values of type
`T` in a FITS Table extension.

"""
const ColumnData{T,N} = AbstractArray{T,N}

"""
    AstroFITS.ColumnUnits

Alias for the possible type(s) for the units of a column in a FITS Table extension.

"""
const ColumnUnits = AbstractString

"""
    AstroFITS.ColumnEltype

Alias for the possible type(s) to specify the types of the values in a column of a FITS
Table extension.

"""
const ColumnEltype = Union{Type,Char}

"""
    AstroFITS.ColumnDims

Alias for the possible type(s) to specify the cell dimensions in a column of a FITS Table
extension.

"""
const ColumnDims = Union{Integer,Tuple{Vararg{Integer}}}

"""
    AstroFITS.ColumnSpec

Alias for the possible type(s) to specify the type of values, cell dimensions, and units of
a column of a FITS Table extension. The element type is mandatory and must be specified
first.

"""
const ColumnSpec = Union{ColumnEltype,
                         Tuple{ColumnEltype},
                         Tuple{ColumnEltype,ColumnUnits},
                         Tuple{ColumnEltype,ColumnDims},
                         Tuple{ColumnEltype,ColumnDims,ColumnUnits},
                         Tuple{ColumnEltype,ColumnUnits,ColumnDims}}

"""
    AstroFITS.ColumnNameSpecPair

Alias for possible type(s) to specify a column when creating a table. Instances of this kind
are pairs like `col => type` or `col => (type,dims,units)` with `col` the column name
number, `type` the type of the column values, `dims` the cell dimensions, and `units` the
units of the values. `dims` and `units` are optional and may appear in any order after
`type` which is mandatory.

"""
const ColumnNameSpecPair = Pair{<:ColumnName,<:ColumnSpec}

"""
    AstroFITS.ColumnIdentDataPair

Alias for possible type(s) to specify a column with its data and, optionally, its units to
be written in a FITS Table extension. Instances of this kind are pairs like `col => vals` or
`col => (vals, units)` with `col` the column name or number, `vals` the column values, and
`units` optional units.

[`AstroFITS.ColumnNameDataPair`](@ref) is similar except that `col` cannot be a column
number.

"""
const ColumnIdentDataPair = Pair{<:ColumnIdent,
                                 <:Union{ColumnData,Tuple{ColumnData,ColumnUnits}}}

"""
    AstroFITS.ColumnNameDataPair

Alias for possible type(s) to specify a column with its data and, optionally, its units to
be written in a FITS Table extension. Instances of this kind are pairs like `col => vals` or
`col => (vals, units)` with `col` the column name, `vals` the column values, and `units`
optional units.

[`AstroFITS.ColumnIdentDataPair`](@ref) is similar except that `col` can be a column number.

"""
const ColumnNameDataPair = Pair{<:ColumnName,
                                <:Union{ColumnData,Tuple{ColumnData,ColumnUnits}}}

"""
    AstroFITS.TableData

Union of types that can possibly be that of FITS Table data. Instances of this kind are
collections of `key => vals` or `key => (vals, units)` pairs with `key` the column name,
`vals` the column values, and `units` the optional units of these values. Such collections
can be dictionaries, named tuples, vectors, or tuples.

For table data specified by dictionaries or vectors, the names of the columns must all be
of the same type.

Owing to the variety of possibilities for representing column values with optional units,
`AstroFITS.TableData` cannot be specific for the values of the pairs in the collection. The
package therefore rely on *error catcher* methods to detect column with invalid associated
data.

Another consequence is that there is a non-empty intersection between `AstroFITS.TableData`
and `AstroFITS.Header` which imposes to rely on position of arguments to distinguish them.

"""
const TableData = Union{AbstractDict{<:ColumnName,<:Any},
                        AbstractVector{<:Pair{<:ColumnName,<:Any}},
                        Tuple{Vararg{Pair{<:ColumnName,<:Any}}},
                        NamedTuple}

"""
    FitsHDU

Abstract type of FITS Header Data Units (HDU). Each HDU consist in a header and a data
parts. Concrete instances of `FitsHDU` behave as vectors whose elements are FITS header
records, a.k.a. FITS cards, and which can be indexed by integers or by names.

For faster access to the records of a header, consider creating a FITS header object from a
HDU object with:

    hdr = FitsHeader(hdu::FitsHDU)

"""
abstract type FitsHDU <: AbstractVector{FitsCard} end

# Enumeration of HDU type identifiers.
@cenum FitsHDUType::Cint begin
    FITS_IMAGE_HDU = CFITSIO.IMAGE_HDU
    FITS_BINARY_TABLE_HDU = CFITSIO.BINARY_TBL
    FITS_ASCII_TABLE_HDU = CFITSIO.ASCII_TBL
    FITS_ANY_HDU = CFITSIO.ANY_HDU
end

mutable struct FitsFile <: AbstractVector{FitsHDU}
    handle::Ptr{CFITSIO.fitsfile}
    mode::Symbol
    path::String
    nhdus::Int
end

"""
    AstroFITS.Invalid

Singleton type of the object used to indicate invalid arguments while sparing throwing an
exception.

"""
struct Invalid end

# Any other FITS extension than Image and Table (who knows...).
struct FitsAnyHDU <: FitsHDU
    file::FitsFile
    num::Int
    # Private inner constructor.
    global _FitsAnyHDU
    _FitsAnyHDU(file::FitsFile, num::Integer) = new(file, num)
end

# FITS Image extension (Array for Julia).
struct FitsImageHDU{T,N} <: FitsHDU
    file::FitsFile
    num::Int
    # Private inner constructor.
    global _FitsImageHDU
    function _FitsImageHDU(::Type{T}, ::Type{Dims{N}},
                           file::FitsFile, num::Integer) where {T,N}
        isbitstype(T) || bad_argument("parameter `T=$T` is not a plain type")
        isa(N, Int) && N ≥ 0 || bad_argument("parameter `N=$N` must be a nonnegative `Int`")
        return new{T,N}(file, num)
    end
end

# FITS Table extension.
struct FitsTableHDU <: FitsHDU
    file::FitsFile
    num::Int
    ascii::Bool
    # Private inner constructor.
    global _FitsTableHDU
    _FitsTableHDU(file::FitsFile, num::Integer, ascii::Bool) = new(file, num, ascii)
end

"""
    FitsLogic()

Singleton object indicating that FITS rules should be applied for some logical operation.
For example:

    isequal(FitsLogic(), s1, s2)

compares strings `s1` and `s2` according to FITS rules, that is case of letters and trailing
spaces are irrelevant.

    isequal(FitsLogic(), x) -> f

yields a predicate function `f` such that `f(y)` yields `isequal(FitsLogic(),x,y)`.

"""
struct FitsLogic end

struct Bit end

"""
    FitsError <: Exception

Type of exceptions thrown when an error occurs in the FITSIO library used to manage FITS
files.

"""
struct FitsError <: Exception
    code::Cint
end
