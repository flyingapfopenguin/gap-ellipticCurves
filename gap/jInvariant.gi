
InstallMethod(GetJInvariant,
	"for an object in `IsEllipticCurve'",
	[ IsEllipticCurve ],
	function(curve)
		local discriminant, coeffs, b2, b4, j;
		discriminant := Discriminant(curve);
		Assert(0, discriminant<>0);
		coeffs := FamilyObj(curve)!.coefficients;
		b2 := coeffs[1]^2 + 4*coeffs[2];
		b4 := 2*coeffs[4] + coeffs[1]*coeffs[3];
		j := ( b2^2 - 24*b4 )^3 / discriminant;
		return j;
	end
);

InstallMethod(EllipticCurveFromjInvariant,
	"for an integer and a field",
	[ IsInt, IsField ],
	function(j, field)
		local denominator;
		if IsZero(j*One(field)) then
			if Characteristic(field) = 2 then
				return EllipticCurve([0, 0, 1, 0, 0, 0], field);
			fi;
			if Characteristic(field) = 3 then
				return EllipticCurve([0, 0, 0, 1, 0, 0], field);
			fi;
			return EllipticCurve([0, 0, 0, 0, 0, 1], field);
		fi;
		denominator := (1728-j)*One(field);
		if IsZero(denominator) then
			return EllipticCurve([0, 0, 0, 1, 0, 0], field);
		fi;
		return EllipticCurve([0, 0, 0, 3*j/denominator, 0, 2*j/denominator], field);
	end
);

InstallMethod(Twists,
	"for an object in `IsEllipticCurve'",
	[ IsEllipticCurve ],
	function(curve)
		local j, field, coeffs, primitiveElement, ResCoeffsList;
		if not IsInShortWeierstrassForm(curve) then
			TryNextMethod();
		fi;
		j := GetJInvariant(curve);
		field := FamilyObj(curve)!.field;
		coeffs := FamilyObj(curve)!.coefficients;
		primitiveElement := PrimitiveElement(field);
		if j = 0 then
			ResCoeffsList := List([0..5], i -> primitiveElement^i * coeffs);
		elif j = 1728 then
			ResCoeffsList := List([0..3], i -> primitiveElement^i * coeffs);
		else
			ResCoeffsList := [ coeffs, [0, 0, 0, primitiveElement^2 * coeffs[4], 0, primitiveElement^3 * coeffs[6]] ];
		fi;
		return List(ResCoeffsList, c -> EllipticCurve(c, field));
	end
);
