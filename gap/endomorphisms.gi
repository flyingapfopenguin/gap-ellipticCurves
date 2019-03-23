
#########################
### CONSTRUCTORS
#########################

InstallMethod(EllipticCurveEndomorphismRing,
	"for an object in `IsEllipticCurve'",
	[ IsEllipticCurve ],
	function(curve)
		local famCurve, fam, R;
		if not IsInShortWeierstrassForm(curve) then
			TryNextMethod();
		fi;
		famCurve := FamilyObj(curve);
		fam:=CollectionsFamily(GeneralMappingsFamily(ElementsFamily(famCurve), ElementsFamily(famCurve)));
		fam!.curve:=curve;
		R:=Objectify(NewType(fam, IsEllipticCurveEndomorphismRing and IsAttributeStoringRep), rec());
		Assert(0, R <> fail);
		return R;
	end
);

# TODO verify rational functions define an endomorphism
InstallMethod(EllipticCurveEndomorphism,
	"for an object in `IsEllipticCurveEndomorphismRing' and two univariate rational functions",
	[ IsEllipticCurveEndomorphismRing, IsUnivariateRationalFunction, IsUnivariateRationalFunction ],
	function(EndRing, ratFuncR, ratFuncS)
		local fam, obj;
		fam := FamilyObj(EndRing);
		obj := Objectify( NewType(ElementsFamily(fam), IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep),
			rec(R:=ratFuncR, S:=ratFuncS));
		SetSource(obj, fam!.curve);
		SetRange(obj, fam!.curve);
		return obj;
	end
);

InstallMethod(EllipticCurveEndomorphism,
	"for an object in `IsEllipticCurve' and two univariate rational functions",
	[ IsEllipticCurve, IsUnivariateRationalFunction, IsUnivariateRationalFunction ],
	function(curve, ratFuncR, ratFuncS)
		if not IsInShortWeierstrassForm(curve) then
			TryNextMethod();
		fi;
		return EllipticCurveEndomorphism(EllipticCurveEndomorphismRing(curve), ratFuncR, ratFuncS);
	end
);

InstallMethod(EllipticCurveEndomorphism,
	"for an object in `IsEllipticCurve' and an integer",
	[ IsEllipticCurve, IsInt ],
	function(curve, n)
		local endomorphism, x, field, R, S;
		endomorphism := n*One(EllipticCurveEndomorphismRing(curve));
		x := IndeterminateOfUnivariateRationalFunction(endomorphism!.R);
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism!.S));
		field := FamilyObj(curve)!.field;
		R := ( NumeratorOfRationalFunction(endomorphism!.R) mod (x^Size(field)-x) )
			/ ( DenominatorOfRationalFunction(endomorphism!.R) mod (x^Size(field)-x) );
		S := ( NumeratorOfRationalFunction(endomorphism!.S) mod (x^Size(field)-x) )
			/ ( DenominatorOfRationalFunction(endomorphism!.S) mod (x^Size(field)-x) );
		return EllipticCurveEndomorphism(curve, R, S);
	end
);

#########################
### Print functions
#########################

InstallMethod(PrintObj,
	"for object in `IsEllipticCurveEndomorphism'",
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism)
		Print("endomoprhism on ", String(CollectionsFamily(FamilyObj(endomorphism))!.curve), " with R = ", endomorphism!.R, " and S = ", endomorphism!.S);
	end
);

InstallMethod(ViewObj,
	"for object in `IsEllipticCurveEndomorphism'",
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism)
		Print("endo. with R = ", endomorphism!.R, " and S = ", endomorphism!.S);
	end
);

#########################
### Zero as add. NE
#########################

InstallMethod(ZeroImmutable,
	"for an object in `IsEllipticCurveEndomorphismRing'",
	[ IsEllipticCurveEndomorphismRing ],
	#101, # the prio is needed to beat the One method in lib/memory.gi
	function(EndRing)
		local curve, field, x, RS;
		curve := FamilyObj(EndRing)!.curve;
		field := FamilyObj(curve)!. field;
		x := Indeterminate(field, "x");
		RS := 0*x^0;
		return EllipticCurveEndomorphism(EndRing, RS, RS);
	end
);

InstallMethod(ZeroImmutable,
	"for an object in `IsEllipticCurveEndomorphism'",
	[ IsEllipticCurveEndomorphism ],
	function(endomorphism)
		local curve;
		curve := CollectionsFamily(FamilyObj(endomorphism))!.curve;
		return ZeroImmutable(EllipticCurveEndomorphismRing(curve));
	end
);

InstallMethod(IsZero,
	"for an object in `IsEllipticCurveEndomorphism'",
	[IsEllipticCurveEndomorphism],
	function(p)
		return p = Zero(p);
	end
);

#########################
### One as mult. NE
#########################

InstallMethod(OneImmutable,
	"for an object in `IsEllipticCurveEndomorphismRing'",
	[ IsEllipticCurveEndomorphismRing ],
	101, # the prio is needed to beat the One method in lib/memory.gi
	function(EndRing)
		local curve, field, x, R, S;
		curve := FamilyObj(EndRing)!.curve;
		field := FamilyObj(curve)!.field;
		x := Indeterminate(field, "x");
		R := x;
		S := x^0;
		return EllipticCurveEndomorphism(EndRing, R, S);
	end
);

InstallMethod(OneImmutable,
	"for an object in `IsEllipticCurveEndomorphism'",
	[ IsEllipticCurveEndomorphism ],
	function(endomorphism)
		local curve;
		curve := CollectionsFamily(FamilyObj(endomorphism))!.curve;
		return OneImmutable(EllipticCurveEndomorphismRing(curve));
	end
);

InstallMethod(IsOne,
	"for an object in `IsEllipticCurveEndomorphism'",
	[IsEllipticCurveEndomorphism],
	function(p)
		return p = One(p);
	end
);

#########################
### Operators on endomorphism
#########################

InstallMethod(\=,
	"for object in `IsEllipticCurveEndomorphism'",
	IsIdenticalObj,
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep, IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism1, endomorphism2)
		local curve;
		if (endomorphism1!.R = endomorphism2!.R)
			and (endomorphism1!.S = endomorphism2!.S) then
			return true;
		fi;
		# This can be speeded up (and computable on infinte curves)
		# by using a unique representation of each endomorphism
		curve := CollectionsFamily(FamilyObj(endomorphism1))!.curve;
		if not IsFinite(curve) then
			TryNextMethod();
		fi;
		return ForAll( Elements(curve), p -> p^endomorphism1 = p^endomorphism2);
	end
);

InstallMethod(\<,
	"for object in `IsEllipticCurveEndomorphism'",
	IsIdenticalObj,
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep, IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism1, endomorphism2)
		local curve, p;
		if IsZero(endomorphism2) then
			return false;
		fi;
		if IsZero(endomorphism1) then
			return true;
		fi;
		# This can be speeded up (and computable on infinte curves)
		# by using a unique representation of each endomorphism
		curve := CollectionsFamily(FamilyObj(endomorphism1))!.curve;
		if not IsFinite(curve) then
			TryNextMethod();
		fi;
		for p in Elements(curve) do
			if (p^endomorphism1 = p^endomorphism2) then
				continue;
			fi;
			return (p^endomorphism1 < p^endomorphism2);
		od;
		return false;
	end
);

InstallMethod(\+,
	"for two objects in `IsEllipticCurveEndomorphism'",
	IsIdenticalObj,
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep, IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism1, endomorphism2)
		local x, y2, curve, coeffs, M, R, S;
		# assert indeterminates are equal
		x := IndeterminateOfUnivariateRationalFunction(endomorphism1!.R);
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism1!.S));
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism2!.R));
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism2!.S));
		if IsZero(endomorphism1) then
			# TODO this shouldn't be needed, but it is
			if IsZero(endomorphism2) then
				return Zero(endomorphism1);
			fi;
			return endomorphism2;
		fi;
		if IsZero(endomorphism2) then
			return endomorphism1;
		fi;
		if -endomorphism1 = endomorphism2 then
			return Zero(endomorphism1);
		fi;
		curve := CollectionsFamily(FamilyObj(endomorphism1))!.curve;
		coeffs := FamilyObj(curve)!.coefficients;
		y2 := x^3 + coeffs[4]*x + coeffs[6];
		if not (endomorphism1!.R = endomorphism2!.R) then
			M := ( endomorphism2!.S - endomorphism1!.S ) / ( endomorphism2!.R - endomorphism1!.R );
		else
			Assert(0, not IsZero( endomorphism1!.S + endomorphism2!.S ));
			M := ( endomorphism1!.R^2 + endomorphism1!.R*endomorphism2!.R + endomorphism2!.R^2 + coeffs[4] )
				/ ( ( endomorphism1!.S + endomorphism2!.S ) * y2 );
		fi;
		R := M^2 * y2 - endomorphism1!.R - endomorphism2!.R;
		S := M * ( endomorphism1!.R - R ) - endomorphism1!.S;
		return EllipticCurveEndomorphism(curve, R, S);
	end
);

InstallMethod(\*,
	"for two objects in `IsEllipticCurveEndomorphism'",
	IsIdenticalObj,
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep, IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism1, endomorphism2)
		local x, curve, R, S;
		# assert indeterminates are equal
		x := IndeterminateOfUnivariateRationalFunction(endomorphism1!.R);
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism1!.S));
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism2!.R));
		Assert(0, x = IndeterminateOfUnivariateRationalFunction(endomorphism2!.S));
		curve := CollectionsFamily(FamilyObj(endomorphism1))!.curve;
		R := Value(endomorphism2!.R, [x], [endomorphism1!.R]);
		S := Value(endomorphism2!.S, [x], [endomorphism1!.R]) * endomorphism1!.S;
		return EllipticCurveEndomorphism(curve, R, S);
	end
);

InstallMethod(AdditiveInverseOp,
	"for an object in `IsEllipticCurveEndomorphism'",
	[IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep],
	function(endomorphism)
		local curve;
		curve := CollectionsFamily(FamilyObj(endomorphism))!.curve;
		return EllipticCurveEndomorphism(curve, endomorphism!.R, -endomorphism!.S);
	end
);

#########################
### Apply point on elliptic curve
#########################

InstallMethod(\^,
	"for object in `IsPointOnEllipticCurve' and an object in `IsEllipticCurveEndomorphism`",
	[ IsPointOnEllipticCurve and IsPointOnEllipticCurveRep, IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep ],
	function(p, endomorphism)
		local curve, var, x, y;
		curve := CollectionsFamily(FamilyObj(endomorphism))!.curve;
		if not (p in curve) then
			TryNextMethod();
		fi;
		if IsOne(p) then
			return One(curve);
		fi;
		# assert indeterminates are equal
		var := IndeterminateOfUnivariateRationalFunction(endomorphism!.R);
		Assert(0, var = IndeterminateOfUnivariateRationalFunction(endomorphism!.S));
		if IsZero(Value(DenominatorOfRationalFunction(endomorphism!.R), [var], [p!.coordinates[1]]))
			or IsZero(Value(DenominatorOfRationalFunction(endomorphism!.S), [var], [p!.coordinates[1]])) then
			return One(curve);
		fi;
		x := Value(endomorphism!.R, [var], [p!.coordinates[1]]);
		y := Value(endomorphism!.S, [var], [p!.coordinates[1]]) * p!.coordinates[2];
		if not AreCoordinatesOnCurve([x,y], curve) then
			return One(curve);
		fi;
		return PointOnEllipticCurve([x,y], curve);
	end
);

# TODO implement degree of endomorphism
