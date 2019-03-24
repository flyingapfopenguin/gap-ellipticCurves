
InstallMethod(Divisionpolynomial,
	"for an object in `IsEllipticCurve' and an integer",
	[ IsEllipticCurve, IsInt ],
	function(curve, n)
		local field, x, y, a, b, res, m;
		if not IsInShortWeierstrassForm(curve) then
			TryNextMethod();
		fi;
		if IsNegInt(n) then
			return -Divisionpolynomial(curve, -n);
		fi;
		field := FamilyObj(curve)!.field;
		x := Indeterminate(field, "x");
		y := Indeterminate(field, "y");
		if IsZero(n) then
			return [ 0*x^0, [x,y] ];
		fi;
		if IsOne(n) then
			return [ x^0, [x,y] ];
		fi;
		if n = 2 then
			return [ 2*y, [x,y] ];
		fi;
		a := FamilyObj(curve)!.coefficients[4];
		b := FamilyObj(curve)!.coefficients[6];
		if n = 3 then
			res := 3*x^4+6*a*x^2+12*b*x-a^2;
			return [ res, [x,y] ];
		fi;
		if n = 4 then
			res := 4*y*(x^6+5*a*x^4+20*b*x^3-5*a^2*x^2-4*a*b*x-8*b^2-a^3);
			return [ res, [x,y] ];
		fi;
		if IsEvenInt(n) then
			m := n/2;
			res := (2*y)^(-1) * Divisionpolynomial(curve, m)[1] * ( Divisionpolynomial(curve, m+2)[1] * Divisionpolynomial(curve, m-1)[1]^2
				- Divisionpolynomial(curve, m-2)[1] * Divisionpolynomial(curve, m+1)[1]^2 );
			Assert(0, IsPolynomial(res));
			return [ res, [x,y] ];
		fi;
		m := (n-1)/2;
		res := Divisionpolynomial(curve, m+2)[1] * Divisionpolynomial(curve, m)[1]^3 - Divisionpolynomial(curve, m-1)[1] * Divisionpolynomial(curve, m+1)[1]^3;
		return [ res, [x,y] ];
	end
);

InstallMethod(DivisionpolynomialSubstitutedY,
	"for an object in `IsEllipticCurve' and an integer",
	[ IsEllipticCurve, IsInt ],
	function(curve, n)
		local divisionpolynomial, x, y, a, b, res;
		if not IsInShortWeierstrassForm(curve) then
			TryNextMethod();
		fi;
		divisionpolynomial := Divisionpolynomial(curve, n);
		x := divisionpolynomial[2][1];
		y := divisionpolynomial[2][2];
		a := FamilyObj(curve)!.coefficients[4];
		b := FamilyObj(curve)!.coefficients[6];
		res := Value(divisionpolynomial[1], [y^2], [x^3 + a*x + b]);
		Assert(0, IsUnivariatePolynomial(res));
		return res;
	end
);

InstallMethod(SchoofModP,
	"for an object in `IsEllipticCurve' and a prime",
	[ IsEllipticCurve, IsInt ],
	function(curve, p)
		local field, q, coeffs, x, a, b, endomorphism_2Frobenius_q,
			multEndomorphism, divisionpolynomial_p, i, w, poly, f;
		if not IsInShortWeierstrassForm(curve) then
			TryNextMethod();
		fi;
		if not IsPrimeInt(p) then
			Error(" p must be a prime. ");
		fi;
		field := FamilyObj(curve)!.field;
		q := Size(field);
		if Characteristic(field) = p then
			Error(" p must not be the characteristic of the field. ");
		fi;
		x := Indeterminate(field, "x");
		a := FamilyObj(curve)!.coefficients[4];
		b := FamilyObj(curve)!.coefficients[6];
		if p = 2 then
			if IsOne(Gcd( x^q - x, x^3 + a*x + b )) then
				return 1;
			fi;
			return 0;
		fi;
		endomorphism_2Frobenius_q := EllipticCurveEndomorphism(curve, x^(q^2), (x^3 + a*x + b)^((q^2-1)/2))
			+ (q mod p)*One(EllipticCurveEndomorphismRing(curve));
		multEndomorphism := [];
		divisionpolynomial_p := DivisionpolynomialSubstitutedY(curve, p);
		for i in [1..((p-1)/2)] do
			if i = 1 then
				multEndomorphism[1] := One(EllipticCurveEndomorphismRing(curve));
			else
				multEndomorphism[i] := multEndomorphism[i-1] + One(EllipticCurveEndomorphismRing(curve));
			fi;
			poly := endomorphism_2Frobenius_q!.R - multEndomorphism[i]!.R^q;
			if IsPolynomial(poly) and IsZero( poly mod divisionpolynomial_p ) then
				poly := endomorphism_2Frobenius_q!.S - multEndomorphism[i]!.S^q * (x^3 + a*x + b)^((q-1)/2);
				if IsPolynomial(poly) and IsZero( poly mod divisionpolynomial_p ) then
					return i;
				fi;
				return -i;
			fi;
		od;
		if Legendre(q, p) = -1 then
			return 0;
		fi;
		w := RootFFE(GF(p), q*One(GF(p)), 2);
		Assert(0, w<>fail);
		w := IntFFE(w);
		if w >= (p+1)/2 then
			w := p-w;
		fi;
		poly := x^q - multEndomorphism[w]!.R;
		f := NumeratorOfRationalFunction(poly) mod Gcd(NumeratorOfRationalFunction(poly), DenominatorOfRationalFunction(poly));
		if IsOne(Gcd(f, divisionpolynomial_p)) then
			return 0;
		fi;
		poly := (x^3 + a*x + b)^((q-1)/2) - multEndomorphism[w]!.S;
		f := NumeratorOfRationalFunction(poly) mod Gcd(NumeratorOfRationalFunction(poly), DenominatorOfRationalFunction(poly));
		if IsOne(Gcd(f, divisionpolynomial_p)) then
			return -2*w;
		fi;
		return 2*w;
	end
);

InstallMethod(TraceOfFrobeniusBySchoof,
	"for an object in `IsEllipticCurve'",
	[ IsEllipticCurve ],
	function(curve)
		local field, char, q, reminders, modPrimes, curPrime, prod, t;
		field := FamilyObj(curve)!.field;
		char := Characteristic(field);
		q := Size(field);
		reminders := [];
		modPrimes := [];
		curPrime := 1;
		prod := 1;
		repeat
			curPrime := NextPrimeInt(curPrime);
			if curPrime = char then
				continue;
			fi;
			Append(reminders, [ SchoofModP(curve, curPrime) ]);
			Append(modPrimes, [ curPrime ]);
			prod := prod * curPrime;
		until 1.0*prod > 4*Sqrt(1.0*q);
		t := ChineseRem(modPrimes, reminders);
		while (1.0*t^2 > 4*Sqrt(1.0*q)) do
			t := t - prod;
		od;
		Assert(0, 1.0*AbsInt(t) <= 2*Sqrt(1.0*q));
		return t;
	end
);

InstallMethod(SizeBySchoof,
	"for an object in `IsEllipticCurve'",
	[ IsEllipticCurve ],
	function(curve)
		local field, q;
		field := FamilyObj(curve)!.field;
		q := Size(field);
		return q+1-TraceOfFrobeniusBySchoof(curve);
	end
);
