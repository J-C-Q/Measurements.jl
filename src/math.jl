### math.jl
#
# Copyright (C) 2016 Mosè Giordano.
#
# Maintainer: Mosè Giordano <mose AT gnu DOT org>
# Keywords: uncertainty, error propagation, physics
#
# This file is a part of Measurements.jl.
#
# License is MIT "Expat".
#
### Commentary:
#
# This file contains definition of mathematical functions that support
# Measurement objects.
#
### Code:

### Elementary arithmetic operations:
import Base: +, -, *, /, div, inv, fld, cld

# Addition: +
+(a::Measurement) = a
+(a::Measurement, b::Measurement) =
    Measurement(promote(a.val + b.val, hypot(a.err, b.err))...)
+(a::Real, b::Measurement) = +(Measurement(a), b)
+(a::Measurement, b::Bool) = +(a, Measurement(b))
+(a::Measurement, b::Rational) = +(a, Measurement(b))
+(a::Measurement, b::Real) = +(a, Measurement(b))

# Subtraction: -
-(a::Measurement) = Measurement(-a.val, a.err)
-(a::Measurement, b::Measurement) = a + (-b)
-(a::Real, b::Measurement) = -(Measurement(a), b)
-(a::Measurement, b::Real) = -(a, Measurement(b))

# Multiplication: *
function *(a::Measurement, b::Measurement)
    prod = a.val*b.val
    if prod == 0
        return Measurement(zero(prod))
    else
        return Measurement(promote(prod, abs(prod)*hypot(a.err*inv(a.val),
                                                         b.err*inv(b.val)))...)
    end
end
*(a::Bool, b::Measurement) = *(Measurement(a), b)
*(a::Measurement, b::Bool) = *(a, Measurement(b))
*(a::Real, b::Measurement) = *(Measurement(a), b)
*(a::Measurement, b::Real) = *(a, Measurement(b))

# Division: /, div, fld, cld
function /(a::Measurement, b::Measurement)
    div = a.val*inv(b.val)
    if div == 0
        return Measurement(zero(div))
    else
        return Measurement(promote(div, abs(div)*(hypot(a.err*inv(a.val),
                                                        b.err*inv(b.val))))...)
    end
end
/(a::Real, b::Measurement) = /(Measurement(a), b)
/(a::Measurement, b::Real) = /(a, Measurement(b))

div(a::Measurement, b::Measurement) = Measurement(div(a.val, b.val))
div(a::Measurement, b::Real) = div(a, Measurement(b))
div(a::Real, b::Measurement) = div(Measurement(a), b)

fld(a::Measurement, b::Measurement) = Measurement(fld(a.val, b.val))
fld(a::Measurement, b::Real) = fld(a, Measurement(b))
fld(a::Real, b::Measurement) = fld(Measurement(a), b)

cld(a::Measurement, b::Measurement) = Measurement(cld(a.val, b.val))
cld(a::Measurement, b::Real) = cld(a, Measurement(b))
cld(a::Real, b::Measurement) = cld(Measurement(a), b)

# Inverse: inv
function inv(a::Measurement)
    inverse = inv(a.val)
    return Measurement(promote(inverse, inverse*inverse*a.err)...)
end

# signbit
import Base: signbit

signbit(a::Measurement) = signbit(a.val)

# Power: ^
import Base: ^, exp2

function ^(a::Measurement, b::Measurement)
    if b == -1
        return inv(a)
    else
        pow = a.val^b.val
        return Measurement(promote(pow, hypot(pow*inv(a.val)*b.val*a.err,
                                              pow*log(a.val)*b.err))...)
    end
end
^{T<:Integer}(a::Measurement, b::T) = ^(a, Measurement(b))
^{T<:Rational}(a::Measurement, b::T) = ^(a, Measurement(b))
^{T<:Real}(a::Measurement,  b::T) = ^(a, Measurement(b))
^{T<:Integer}(a::T, b::Measurement) = ^(Measurement(a), b)
^(::Irrational{:e}, b::Measurement) = exp(b)
^(a::Irrational, b::Measurement) = Measurement(float(a))^b
^{T<:Real}(a::T,  b::Measurement) = ^(Measurement(a), b)

function exp2{T<:AbstractFloat}(a::Measurement{T})
    pow = exp2(a.val)
    return Measurement(promote(pow, abs(pow*log(T(2))*a.err))...)
end

# Cosine: cos, cosh
import Base: cos, cosh

cos(a::Measurement) =
    Measurement(promote(cos(a.val), abs(sin(a.val)*a.err))...)
cosh(a::Measurement) =
    Measurement(promote(cosh(a.val), abs(sinh(a.val)*a.err))...)

# Sine: sin, sinh
import Base: sin, sinh

sin(a::Measurement) =
    Measurement(promote(sin(a.val), abs(cos(a.val)*a.err))...)
sinh(a::Measurement) =
    Measurement(promote(sinh(a.val), abs(cosh(a.val)*a.err))...)

# Tangent: tan, tand, tanh
import Base: tan, tand, tanh

function tan(a::Measurement)
    seca = sec(a.val)
    return Measurement(promote(tan(a.val), abs(seca*seca*a.err))...)
end

# TODO: remove when correlation will be supported
tand(a::Measurement) = tan(deg2rad(a))

function tanh(a::Measurement)
    secha = sech(a.val)
    return Measurement(promote(tanh(a.val), abs(secha*secha*a.err))...)
end

# Inverse trig functions: acos, acosh, asin, asinh, atan, atan2, atanh
import Base: acos, acosh, asin, asinh, atan, atan2, atanh

acos(a::Measurement) =
    Measurement(promote(acos(a.val), abs(a.err*inv(sqrt(1.0 - a.val*a.val))))...)
acosh(a::Measurement) =
    Measurement(promote(acosh(a.val), abs(a.err*inv(sqrt(a.val*a.val - 1.0))))...)

asin(a::Measurement) =
    Measurement(promote(asin(a.val), abs(a.err*inv(sqrt(1.0 - a.val*a.val))))...)
asinh(a::Measurement) =
    Measurement(promote(asinh(a.val), abs(a.err*inv(hypot(a.val, 1.0))))...)

atan(a::Measurement) =
    Measurement(promote(atan(a.val), abs(a.err*inv(a.val*a.val + 1.0)))...)
atanh(a::Measurement) =
    Measurement(promote(atanh(a.val), abs(a.err*inv(1.0 - a.val*a.val)))...)
function atan2(a::Measurement, b::Measurement)
    invdenom = inv(a.val*a.val + b.val*b.val)
    return Measurement(promote(atan2(a.val, b.val),
                               hypot(a.err*b.val*invdenom,
                                     b.err*a.val*invdenom))...)
end
atan2(a::Measurement, b::Real) = atan2(a, Measurement(b))
atan2(a::Real, b::Measurement) = atan2(Measurement(a), b)

# Reciprocal trig functions: csc, cscd, csch, sec, secd, sech, cot, cotd, coth
import Base: csc, cscd, csch, sec, secd, sech, cot, cotd, coth

function csc(a::Measurement)
    val = csc(a.val)
    return Measurement(promote(val, abs(a.err*val*cot(a.val)))...)
end

# TODO: remove when correlation will be supported
cscd(a::Measurement) = rad2deg(csc(a))

function csch(a::Measurement)
    val = csch(a.val)
    return Measurement(promote(val, abs(a.err*val*coth(a.val)))...)
end

function sec(a::Measurement)
    val = sec(a.val)
    return Measurement(promote(val, abs(a.err*val*tan(a.val)))...)
end

# TODO: remove when correlation will be supported
secd(a::Measurement) = rad2deg(sec(a))

function sech(a::Measurement)
    val = sech(a.val)
    return Measurement(promote(val, abs(a.err*val*tanh(a.val)))...)
end

function cot(a::Measurement)
    csca = csc(a.val)
    return Measurement(promote(cot(a.val), abs(a.err*csca*csca))...)
end

# TODO: remove when correlation will be supported
cotd(a::Measurement) = rad2deg(cot(a))

function coth(a::Measurement)
    cscha = csch(a.val)
    return Measurement(promote(coth(a.val), abs(a.err*cscha*cscha))...)
end

# Exponentials: exp, expm1, exp10, frexp, ldexp
import Base: exp, expm1, exp10, frexp, ldexp

function exp(a::Measurement)
    val = exp(a.val)
    return Measurement(promote(val, abs(val*a.err))...)
end

expm1(a::Measurement) =
    Measurement(promote(expm1(a.val), abs(exp(a.val)*a.err))...)

function exp10{T<:AbstractFloat}(a::Measurement{T})
    val = exp10(a.val)
    return Measurement(promote(float(val), abs(log(T(10))*val*a.err))...)
end

function frexp(a::Measurement)
    x, y = frexp(a.val)
    return (Measurement(x, a.err/2^y), y)
end

ldexp(a::Measurement, e::Integer) = Measurement(ldexp(a.val, e), ldexp(a.err, e))

# Logarithm: log, log10, log1p
import Base: log, log10, log1p

function log(a::Measurement, b::Measurement)
    val = log(a.val, b.val)
    loga = log(a.val)
    logb = val*loga # This should avoid some calculations
    return Measurement(promote(val, hypot(a.err*val*inv(a.val*loga),
                                          b.err*inv(loga*b.val)))...)
end
log(a::Measurement) = # Special case
    Measurement(promote(log(a.val), a.err*inv(a.val))...)
log10{T<:AbstractFloat}(a::Measurement{T}) = # Special case
    Measurement(promote(log10(a.val), a.err*inv(log(T(10))*a.val))...)
log1p(a::Measurement) = # Special case
    Measurement(promote(log1p(a.val), a.err*inv(a.val + one(a.val)))...)
log(::Irrational{:e}, a::Measurement) = log(a)
log(a::Real, b::Measurement) = log(Measurement(a), b)
log(a::Irrational, b::Measurement) = log(float(a), b)
log(a::Measurement, b::Real) = log(a, Measurement(b))

# Hypotenuse: hypot
import Base: hypot

function hypot(a::Measurement, b::Measurement)
    val = hypot(a.val, b.val)
    return Measurement(promote(val, abs(hypot(a.val*a.err,
                                              b.val*b.err)*inv(val)))...)
end
hypot(a::Real, b::Measurement) = hypot(Measurement(a), b)
hypot(a::Measurement, b::Real) = hypot(a, Measurement(b))

# Square root: sqrt
import Base: sqrt

function sqrt(a::Measurement)
    val = sqrt(a.val)
    return Measurement(promote(val, 0.5*a.err*inv(val))...)
end

# Cube root: cbrt
import Base: cbrt

function cbrt(a::Measurement)
    val = cbrt(a.val)
    return Measurement(promote(val, a.err*val*inv(3.0*a.val))...)
end

# Absolute value: abs
import Base: abs

abs(a::Measurement) = Measurement(promote(abs(a.val), a.err)...)

# Sign: sign, copysign, flipsign
import Base: sign, copysign, flipsign

sign(a::Measurement) = Measurement(sign(a.val))

copysign(a::Measurement, b::Measurement) =
    Measurement(copysign(a.val, b.val), a.err)
copysign(a::Measurement, b::Real) = copysign(a, Measurement(b))
copysign(a::Signed, b::Measurement) = copysign(Measurement(a), b)
copysign(a::Rational, b::Measurement) = copysign(Measurement(a), b)
copysign(a::Float32, b::Measurement) = copysign(Measurement(a), b)
copysign(a::Float64, b::Measurement) = copysign(Measurement(a), b)
copysign(a::Real, b::Measurement) = copysign(Measurement(a), b)

flipsign(a::Measurement, b::Measurement) =
    Measurement(flipsign(a.val, b.val), a.err)
flipsign(a::Measurement, b::Real) = flipsign(a, Measurement(b))
flipsign(a::Signed, b::Measurement) = flipsign(Measurement(a), b)
flipsign(a::Float32, b::Measurement) = flipsign(Measurement(a), b)
flipsign(a::Float64, b::Measurement) = flipsign(Measurement(a), b)
flipsign(a::Real, b::Measurement) = flipsign(Measurement(a), b)

# Zero: zero
import Base: zero

zero(a::Measurement) = Measurement(zero(a.val))

# One: one
import Base: one

one(a::Measurement) = Measurement(one(a.val))

# Error function: erf, erfinv, erfc, erfcinv, erfcx
import Base: erf, erfinv, erfc, erfcinv, erfcx

function erf{T<:AbstractFloat}(a::Measurement{T})
    aval = a.val
    return Measurement(promote(erf(aval),
                               2*exp(-aval*aval)*a.err/sqrt(T(pi)))...)
end

function erfinv{T<:AbstractFloat}(a::Measurement{T})
    result = erfinv(a.val)
    # For the derivative, see http://mathworld.wolfram.com/InverseErf.html
    return Measurement(promote(result,
                               0.5*sqrt(T(pi))*exp(result*result)*a.err)...)
end

function erfc{T<:AbstractFloat}(a::Measurement{T})
    aval = a.val
    return Measurement(promote(erfc(aval),
                               2*exp(-aval*aval)*a.err/sqrt(T(pi)))...)
end

function erfcinv{T<:AbstractFloat}(a::Measurement{T})
    result = erfcinv(a.val)
    # For the derivative, see http://mathworld.wolfram.com/InverseErfc.html
    return Measurement(promote(result,
                               0.5*sqrt(T(pi))*exp(result*result)*a.err)...)
end

function erfcx{T<:AbstractFloat}(a::Measurement{T})
    aval = a.val
    result = erfcx(aval)
    return Measurement(promote(result,
                               abs(2*(aval*result - inv(sqrt(T(pi)))))*a.err)...)
end

# Factorial and gamma: factorial, gamma, lgamma
import Base: factorial, gamma, lgamma

function factorial(a::Measurement)
    aval = a.val
    fact = factorial(aval)
    return Measurement(promote(fact,
                               abs(fact*a.err*polygamma(0, aval + one(aval))))...)
end

function gamma(a::Measurement)
    aval = a.val
    Γ = gamma(aval)
    return Measurement(promote(Γ,
                               abs(Γ*a.err*polygamma(0, aval)))...)
end

function lgamma(a::Measurement)
    aval = a.val
    return Measurement(promote(lgamma(aval),
                               abs(a.err*polygamma(0, aval)))...)
end

# Modulo: modf, mod, rem, mod2pi
import Base: modf, mod, rem, mod2pi

function modf(a::Measurement)
    frac, int = modf(a.val)
    return (Measurement(frac, a.err), int)
end

mod(a::Measurement, b::Measurement) =
    # To calculate the uncertainty, use the property of "mod" function, see
    # http://docs.julialang.org/en/stable/manual/mathematical-operations/#division-functions
    # TODO: find a smarter way to calculate the uncertainty, if possible.
    Measurement(mod(a.val, b.val), (a - fld(a, b)*b).err)
mod(a::Measurement, b::Real) = mod(a, Measurement(b))
mod(a::Real, b::Measurement) = mod(Measurement(a), b)

rem(a::Measurement, b::Measurement) =
    # To calculate the uncertainty, use the property of "rem" function, see
    # http://docs.julialang.org/en/stable/manual/mathematical-operations/#division-functions
    # TODO: find a smarter way to calculate the uncertainty, if possible.
    Measurement(rem(a.val, b.val), (a - div(a, b)*b).err)
rem(a::Measurement, b::Real) = rem(a, Measurement(b))
rem(a::Real, b::Measurement) = rem(Measurement(a), b)

mod2pi(a::Measurement) = Measurement(mod2pi(a.val), a.err)

# Machine precision: eps, nextfloat, maxintfloat
import Base: eps, nextfloat, maxintfloat

eps{T<:AbstractFloat}(::Type{Measurement{T}}) = eps(T)
eps{T<:AbstractFloat}(a::Measurement{T}) = eps(a.val)

nextfloat(a::Measurement) = nextfloat(a.val)

maxintfloat{T<:AbstractFloat}(::Type{Measurement{T}}) = maxintfloat(T)

# Rounding: round, floor, ceil, trunc
import Base: round, floor, ceil, trunc

round(a::Measurement) = round(a.val)
round{T<:Integer}(::Type{T}, a::Measurement) = round(T, a.val)
floor(a::Measurement) = floor(a.val)
floor{T<:Integer}(::Type{T}, a::Measurement) = floor(T, a.val)
ceil(a::Measurement) = ceil(a.val)
ceil{T<:Integer}(::Type{T}, a::Measurement) = ceil(Integer, a.val)
trunc(a::Measurement) = trunc(a.val)
trunc{T<:Integer}(::Type{T}, a::Measurement) = trunc(T, a.val)