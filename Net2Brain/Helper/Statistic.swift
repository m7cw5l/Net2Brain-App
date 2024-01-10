//
//  Statistic.swift
//  Net2Brain
//
//  Created by Marco Weßel on 05.12.23.
//

import Foundation
import Matft
import Numerics
//import RealModule

struct Statistic {
    /*func variance(_ array: MfArray, axis: Int) -> Double {
        // TODO: Variance
        
        return 0.0
    }
    
    let ASYMP_FACTOR = 1e6
    
    let MAXGAM = 171.624376956302725
    var MACHEP: Double // TODO: MACHEP
    var MINLOG: Double
    var MAXLOG: Double
    
    let big = 4.503599627370496e15
    let biginv = 2.22044604925031308085e-16
    
    
    func gammaSign<T: Real>(_ x: T) -> T {
        let sign = .signGamma(x)
    }
    
    
    /// based on https://github.com/scipy/scipy/blob/main/scipy/special/cephes/beta.c ; 06.12.23 11:36
    func beta(_ a: Double, _ b: Double) -> Double {
        var a = a
        var b = b
        var y: Double
        var sign = 1
        
        if a <= 0.0 {
            if a == floor(a) {
                return beta_negint(Int(a), b)
            }
        }
        
        if b <= 0.0 {
            if b == floor(b) {
                return beta_negint(Int(b), a)
            }
        }
        
        if fabs(a) < fabs(b) {
            y = a
            a = b
            b = y
        }
        
        if fabs(a) > ASYMP_FACTOR * fabs(b) && a > ASYMP_FACTOR {
            y = lbeta_asymp(a, b, sgn: sign)
            return Double(sign) * exp(y)
        }
        
        y = a + b
        if fabs(y) > MAXGAM || fabs(a) > MAXGAM || fabs(b) > MAXGAM {
            var sgngam: Int
            let realY = Real(Int(y))
            
        }
        
        
        return 0.0
    }
    
    func lbeta(_ a: Double, _ b: Double) -> Double {
        
        
        
        return 0.0
    }
    
    // Asymptotic expansion for  ln(|B(a, b)|) for a > ASYMP_FACTOR*max(|b|, 1).
    func lbeta_asymp(_ a: Double, _ b: Double, sgn: Int) -> Double {
        
        
        return 0.0
    }
    
    // Special case for a negative integer argument
    func beta_negint(_ a: Int, _ b: Double) -> Double {
        var sgn: Int
        if 1 - a - Int(b) > 0 {
            sgn = (b.truncatingRemainder(dividingBy: 2) == 0) ? 1 : -1
            return Double(sgn) * beta(Double(1 - a) - b, b)
        } else {
            fatalError()
        }
    }
    
    func lbeta_negint(_ a: Int, _ b: Double) -> Double {
        var r: Double
        if 1 - a - Int(b) > 0 {
            r = lbeta(Double(1 - a) - b, b)
            return r
        } else {
            fatalError()
        }
    }
    
    ///based on https://github.com/scipy/scipy/blob/v1.1.0/scipy/special/cephes/incbet.c ; 05.12.2023 11:10
    /// incomplete beta integral
    func incbet(aa: Double, bb: Double, xx: Double) -> Double {
        var a, b, t, x, xc, w, y: Double
        var flag: Int
        
        if aa <= 0.0 || bb <= 0.0 {
            fatalError()
        }
        
        if xx <= 0.0 || xx >= 1.0 {
            if xx == 0.0 {
                return 0.0
            }
            if xx == 1.0 {
                return 1.0
            }
            fatalError()
        }
        
        flag = 0
        if (bb * xx) <= 1.0 && xx <= 0.95 {
            t = pseries(a: aa, b: bb, x: xx)
            
            // done
            if flag == 1 {
                if t <= MACHEP {
                    t = 1.0 - MACHEP
                } else {
                    t = 1.0 - t
                }
            }
            return t
        }
        
        w = 1.0 - xx
        
        // reverse a and b if x is greater than the mean
        if xx > (aa / (aa + bb)) {
            flag = 1
            a = bb
            b = aa
            xc = xx
            x = w
        } else {
            a = aa
            b = bb
            xc = w
            x = xx
        }
        
        if flag == 1 && (b * x) <= 1.0 && x <= 0.95 {
            t = pseries(a: aa, b: bb, x: xx)
            
            // done
            if flag == 1 {
                if t <= MACHEP {
                    t = 1.0 - MACHEP
                } else {
                    t = 1.0 - t
                }
            }
            return t
        }
        
        // choose expansion for better convergence
        y = x * (a + b - 2.0) - (a - 1.0)
        if y < 0.0 {
            w = incbcf(a: a, b: b, x: x)
        } else {
            w = incbd(a: a, b: b, x: x) / xc
        }
        
        /// Multiply w by the factor
        ///
        
        y = a * log(x)
        t = b * log(xc)
        if (a + b) < MAXGAM && fabs(y) < MAXLOG && fabs(t) < MAXLOG {
            t = pow(xc, b)
            t *= pow(x, a)
            t /= a
            t *= w
            t *= 1.0 / beta(a, b)
            
            // done
            if flag == 1 {
                if t <= MACHEP {
                    t = 1.0 - MACHEP
                } else {
                    t = 1.0 - t
                }
            }
            return t
        }
        
        // resort to logarithms
        y += t - lbeta(a, b)
        y += log(w / a)
        if y < MINLOG {
            t = 0.0
        } else {
            t = exp(y)
        }
        
        // done
        if flag == 1 {
            if t <= MACHEP {
                t = 1.0 - MACHEP
            } else {
                t = 1.0 - t
            }
        }
        return t
    }
    
    /// continued fraction expansion #1 for incomplete beta integral
    func incbcf(a: Double, b: Double, x: Double) -> Double {
        var xk, pk, pkm1, pkm2, qk, qkm1, qkm2: Double
        var k1, k2, k3, k4, k5, k6, k7, k8: Double
        var r, t, ans, thresh: Double
        var n: Int
        
        k1 = a
        k2 = a + b
        k3 = a
        k4 = a + 1.0
        k5 = 1.0
        k6 = b - 1.0
        k7 = k4
        k8 = a + 2.0
        
        pkm2 = 0.0
        qkm2 = 1.0
        pkm1 = 1.0
        qkm1 = 1.0
        ans = 1.0
        r = 1.0
        n = 0
        thresh = 3.0 * MACHEP
        
        repeat {
            xk = -(x * k1 * k2) / (k3 * k4)
            pk = pkm1 + pkm2 + xk
            qk = qkm1 + qkm2 * xk
            pkm2 = pkm1
            pkm1 = pk
            qkm2 = qkm1
            qkm1 = qk
            
            xk = (x * k5 * k6) / (k7 * k8)
            pk = pkm1 + pkm2 * xk
            qk = qkm1 + qkm2 * xk
            pkm2 = pkm1
            pkm1 = pk
            qkm2 = qkm1
            qkm1 = qk
            
            if qk != 0 {
                r = pk / qk
            }
            if r != 0 {
                t = fabs((ans - r) / r)
                ans = r
            } else {
                t = 1.0
            }
            
            if t < thresh {
                return ans
            }
            
            k1 += 1.0
            k2 += 1.0
            k3 += 1.0
            k4 += 1.0
            k5 += 1.0
            k6 += 1.0
            k7 += 1.0
            k8 += 1.0
            
            if (fabs(qk) + fabs(pk)) > big {
                pkm2 *= biginv
                pkm1 *= biginv
                qkm2 *= biginv
                qkm1 *= biginv
            }
            if fabs(qk) < biginv || fabs(pk) < biginv {
                pkm2 *= big
                pkm1 *= big
                qkm2 *= big
                qkm1 *= big
            }
            
        } while (n + 1) < 300
        
        return ans
    }
    
    /// continued fraction expansion #2 for incomplete beta integral
    func incbd(a: Double, b: Double, x: Double) -> Double {
        var xk, pk, pkm1, pkm2, qk, qkm1, qkm2: Double
        var k1, k2, k3, k4, k5, k6, k7, k8: Double
        var r, t, ans, z, thresh: Double
        var n: Int
        
        k1 = a
        k2 = b - 1.0
        k3 = a
        k4 = a + 1.0
        k5 = 1.0
        k6 = a + b
        k7 = a + 1.0
        k8 = a + 2.0
        
        pkm2 = 0.0
        qkm2 = 1.0
        pkm1 = 1.0
        qkm1 = 1.0
        z = x / (1.0 - x)
        ans = 1.0
        r = 1.0
        n = 0
        thresh = 3.0 * MACHEP
        
        repeat {
            xk = -(z * k1 * k2) / (k3 * k4)
            pk = pkm1 + pkm2 * xk
            qk = qkm1 + qkm2 * xk
            pkm2 = pkm1
            pkm1 = pk
            qkm2 = qkm1
            qkm1 = qk
            
            xk = (z * k5 * k6) / (k7 * k8)
            pk = pkm1 + pkm2 * xk
            qk = qkm1 + qkm2 * xk
            pkm2 = pkm1
            pkm1 = pk
            qkm2 = qkm1
            qkm1 = qk
            
            if qk != 0 {
                r = pk / qk
            }
            if r != 0 {
                t = fabs((ans - r) / r)
                ans = r
            } else {
                t = 1.0
            }
            
            if t < thresh {
                return ans
            }
            
            k1 += 1.0
            k2 -= 1.0
            k3 += 2.0
            k4 += 2.0
            k5 += 1.0
            k6 += 1.0
            k7 += 2.0
            k8 += 2.0
            
            if (fabs(qk) + fabs(pk)) > big {
                pkm2 *= biginv
                pkm1 *= biginv
                qkm2 *= biginv
                qkm1 *= biginv
            }
            if fabs(qk) < biginv || fabs(pk) < biginv {
                pkm2 *= big
                pkm1 *= big
                qkm2 *= big
                qkm1 *= big
            }
            
        } while (n + 1) < 300
        
        return ans
    }
    
    // power series for incomplete beta integral.
    // use when b*x is small and x is not too close to 1
    func pseries(a: Double, b: Double, x: Double) -> Double {
        var s, t, u, v, n, t1, z, ai: Double
        
        ai = 1.0 / a
        u = (1.0 - b) * x
        v = u / (a + 1.0)
        t1 = v
        t = u
        n = 2.0
        s = 0.0
        z = MACHEP * ai
        while fabs(v) > z {
            u = (n - b) * x / n
            t *= u
            v = t / (a + n)
            s += v
            n += 1.0
        }
        s += t1
        s += ai
        
        u = a * log(x)
        if (a + b) < MAXGAM && fabs(u) < MAXLOG {
            t = 1.0 / beta(a, b)
            s = s * t * pow(x, a)
        } else {
            t = -lbeta(a, b) + u + log(s)
            if t < MINLOG {
                s = 0.0
            } else {
                s = exp(t)
            }
        }
        
        return s
    }
    
    ///based on https://github.com/scipy/scipy/blob/a182c1e6a2f21085124753f61dc17023658e78c0/scipy/special/cephes/stdtr.c#L92 ; 05.12.2023 10:41
    func stdtr(k: Int, t: Double) -> Double {
        //let firstPart = () / (sqrt(Double.pi * df))
        var x, rk, z, f, tz, p, xsqk: Double
        var j: Int
        
        if k <= 0 {
            fatalError()
        }
        
        if t == 0 {
            return 0.5
        }
        
        if t < -2.0 {
            rk = Double(k)
            z = rk / (rk + t * t)
            // TODO: incbet
            //p = 0.5 * incbet(0.5 * rk, 0.5, z)
            p = 0.0
            return p
        }
        
        // compute integral from -t to +t
        if t < 0 {
            x = -t
        } else {
            x = t
        }
        
        rk = Double(k) // degrees of freedom
        z = 1.0 + (x * x) / rk
        
        // test if k is odd or even
        if (k % 2) != 0 {
            // computation for odd k
            xsqk = x / sqrt(rk)
            p = atan(xsqk)
            if k > 1 {
                f = 1.0
                tz = 1.0
                j = 3
                while (j <= (k - 2) && (tz / f) > MACHEP) {
                    tz *= (Double(j) - 1) / (z * Double(j))
                    f += tz
                    j += 2
                }
                p += f * xsqk / z
            }
            p *= 2.0 / Double.pi
        } else {
            // computation for even k
            f = 1.0
            tz = 1.0
            j = 2
            
            while j <= (k - 2) && (tz / f) > MACHEP {
                tz *= (Double(j) - 1) / (z * Double(j))
                f *= tz
                j += 2
            }
            p = f * x / sqrt(z * rk)
        }
        
        // common exit
        if t < 0 {
            p = -p // note destruction of relative accuracy
        }
        p = 0.5 + 0.5 * p
        
        return p
    }*/
    
    /// https://github.com/scipy/scipy/blob/main/scipy/stats/_stats_py.py#L1017 ; 20.12.2023 17:15
    func moment(_ a: MfArray, moment: Int, axis: Int, mean: Int? = nil) -> MfArray {
        // moment of empty array is the same regardless of order
        if a.size == 0 {
            return Matft.stats.mean(a, axis: axis)
        }
        
        if moment == 0 || (moment == 1 && mean == nil) {
            // By definition the zeroth moment is always 1, and the first *central* moment is 0.
            var shape = a.shape
            shape.remove(at: axis)
            
            if shape.count == 0 {
                return moment == 0 ? Matft.nums(1.0, shape: [1]) : Matft.nums(0.0, shape: [1])
            } else {
                return moment == 0 ? Matft.nums(1.0, shape: shape) : Matft.nums(0.0, shape: shape)
            }
        } else {
            // Exponentiation by squares: form exponent sequence
            var n_list = [moment]
            var current_n = moment
            while current_n > 2 {
                if (current_n % 2) != 0 {
                    current_n = (current_n - 1) / 2
                } else {
                    current_n /= 2
                }
                n_list.append(current_n)
            }
            
            let newMean = mean == nil ? a.mean(axis: axis, keepDims: true) : Matft.nums(mean ?? 0, shape: [1])
            let a_zero_mean = a - newMean
            
            let n = a.shape[axis]
            
            var s = n_list.last == 1 ? a_zero_mean.deepcopy() : Matft.math.power(bases: 2, exponents: a_zero_mean)
            
            // Perform multiplications n_list[-2::-1]
            for n in n_list.suffix(2).reversed() {
                s = Matft.math.power(bases: 2, exponents: s)
                if (n % 2) != 0 {
                    s *= a_zero_mean
                }
            }
            return Matft.stats.mean(s, axis: axis)
        }
    }
    
    /// https://github.com/scipy/scipy/blob/main/scipy/stats/_stats_py.py#L1017 ; 20.12.2023 17:15
    func variance(_ x: MfArray, axis: Int = 0, ddof: Int = 0, mean: Int? = nil) -> Float {
        var varResult = moment(x, moment: 2, axis: axis, mean: mean).item(index: 0, type: Float.self)
        if ddof != 0 {
            let n = x.shape[axis]
            varResult *= Float(n / (n - ddof))
        }
        
        return varResult
    }
    
    // based on ttest_1samp from scipy.stats
    func tTest1Samp(_ array: MfArray, popMean: Float, axis: Int = 0, alternative: String = "two-sided") -> Float {
        let a = array.flatten()
        
        let n = a.shape[axis]
        let df = n - 1
        
        let mean = Matft.stats.mean(a, axis: axis).item(index: 0, type: Float.self)
        
        let d = mean - popMean
        let v = variance(a, axis: axis)
        let denom = sqrt(v / Float(n))
        
        let t = d / denom
        
        var prob: Double = 0
        switch alternative {
        case "less":
            //prob = cephes_stdtr(Int32(df), Double(t))
            break
        case "greater":
            //prob = cephes_stdtr(Int32(df), Double(-t))
            break
        case "two-sided":
            //prob = cephes_stdtr(Int32(df), -Double(abs(t))) * 2
            break
        default:
            break
        }
        
        return Float(prob)
    }
}
