#
# ellipticCurves: A library for ellitpic curves in GAP.
#
# Implementations
#

#########################
### AUX FUNCTIONS
#########################

InstallGlobalFunction(__ellpiticCurve__delta,
	function(coeffs)
		local b2, b4, b6, b8, d;
		Assert(0, Length(coeffs) = 6);
		Assert(0, IsZero(coeffs[5]));
		b2 := coeffs[1]^2 + 4*coeffs[2];
		b4 := 2*coeffs[4] + coeffs[1]*coeffs[3];
		b6 := coeffs[3]^2 + 4*coeffs[6];
		b8 := coeffs[1]^2*coeffs[6] + 4*coeffs[2]*coeffs[6] - coeffs[1]*coeffs[3]*coeffs[4] + coeffs[2]*coeffs[3]^2 - coeffs[4]^2;
		d  := -b2^2*b8 - 8*b4^3 - 27*b6^2 + 9*b2*b4*b6;
		return d;
	end
);

InstallGlobalFunction(__ellpiticCurve__AreCoordsOnCurve,
	function(coords, coeffs)
		local r;
		if IsEmpty(coords) then
			return true;
		fi;
		Assert(0, Length(coords) = 2);
		r := coords[2]^2 + coeffs[1]*coords[1]*coords[2] + coeffs[3]*coords[2]
			- ( coords[1]^3 + coeffs[2]*coords[1]^2 + coeffs[4]*coords[1] + coeffs[6] );
		return IsZero(r);
	end
);

InstallGlobalFunction(__ellpiticCurve__GetDefiningEquation,
	function(coeffs, field)
		local x, y, poly;
		x:=Indeterminate(field, "x");
		y:=Indeterminate(field, "y");
		poly:=y^2+coeffs[1]*x*y+coeffs[3]*y-x^3-coeffs[2]*x^2-coeffs[4]*x-coeffs[6];
		return [ poly, [x,y] ];
	end
);

#########################
### CONSTRUCTORS
#########################

InstallMethod(EllipticCurve,
	"for a dense list and a field",
	[ IsDenseList, IsField ],
	function(coeffs, f)
		local fam, G;
		Assert(0, Length(coeffs) in [2,6]);
		if Length(coeffs) = 6 then
			Assert(0, IsZero(coeffs[5]));
		else
			coeffs:=[0, 0, 0, coeffs[1], 0, coeffs[2]];
		fi;
		coeffs:=coeffs*One(f);
		if IsZero(__ellpiticCurve__delta(coeffs)) then
			Error(" Given curve is not singular. ");
		fi;
		fam:=CollectionsFamily(NewFamily(Concatenation("points on elliptic curve with ", String(__ellpiticCurve__GetDefiningEquation(coeffs, f)[1]), " over ", String(f)), IsPointOnEllipticCurve));
		fam!.coefficients:=coeffs;
		fam!.field:=f;
		G:=Objectify(NewType(fam, IsEllipticCurve and IsAttributeStoringRep), rec());
		Assert(0, G <> fail);
		SetIsWholeFamily(G, true);
		SetName(G, Concatenation("elliptic curve with ", String(__ellpiticCurve__GetDefiningEquation(coeffs, f)[1]), " over ", String(f)) );
		if IsFinite(f) then 
			SetIsFinite(G, true);
		fi;
		return G;
	end
);

InstallMethod(PointOnEllipticCurve,
	"for a dense list and an object in `IsFamily'",
	[ IsDenseList, IsFamily ],
	function(coords, fam)
		Assert(0, Length(coords) in [0,2]);
		if not __ellpiticCurve__AreCoordsOnCurve(coords, fam!.coefficients) then
			Error(" Given coordinates describe a point that is not on the given curve. ");
		fi;
		return Objectify( NewType(ElementsFamily(fam), IsPointOnEllipticCurve and IsPointOnEllipticCurveRep),
			rec(coordinates:=coords*One(fam!.field)));
	end
);

InstallMethod(PointOnEllipticCurve,
	"for a dense list and an object in `IsEllipticCurve'",
	[ IsDenseList, IsEllipticCurve ],
	function(coords, G)
		return PointOnEllipticCurve(coords, FamilyObj(G));
	end
);

InstallMethod(PointOnEllipticCurve,
	"for a dense list and an object in `IsPointOnEllipticCurve'",
	[ IsDenseList, IsPointOnEllipticCurve ],
	function(coords, p)
		return PointOnEllipticCurve(coords, CollectionsFamily(FamilyObj(p)));
	end
);

#########################
### Properties of elliptic curves
#########################

InstallMethod(IsInShortWeierstrassForm,
	"for an object in `IsEllipticCurve'",
	[IsEllipticCurve],
	function(G)
		local coeffs;
		coeffs:=FamilyObj(G)!.coefficients;
		return ForAll( List([1..3], i->coeffs[i]), IsZero );
	end
);

InstallMethod(Discriminant,
	"for an object in `IsEllipticCurve'",
	[IsEllipticCurve],
	function(G)
		local coeffs;
		coeffs:=FamilyObj(G)!.coefficients;
		return __ellpiticCurve__delta(coeffs);
	end
);

InstallMethod(AreCoordinatesOnCurve,
	"for a dense list and an object in `IsEllipticCurve'",
	[IsDenseList, IsEllipticCurve],
	function(coords, G)
		local coeffs;
		coeffs:=FamilyObj(G)!.coefficients;
		return __ellpiticCurve__AreCoordsOnCurve(coords, coeffs);
	end
);

InstallMethod(GetDefiningEquation,
	"for an object in `IsEllipticCurve'",
	[IsEllipticCurve],
	function(G)
		local coeffs, field;
		coeffs:=FamilyObj(G)!.coefficients;
		field:=FamilyObj(G)!.field;
		return __ellpiticCurve__GetDefiningEquation(coeffs, field);
	end
);

#########################
### Print functions
#########################

InstallMethod(PrintObj,
	"for object in `IsPointOnEllipticCurve'",
	[IsPointOnEllipticCurve and IsPointOnEllipticCurveRep],
	function(point)
		if IsOne(point) then
			Print("infinite point");
		else
			Print("point ", point!.coordinates);
		fi;
	end
);

InstallMethod(ViewObj,
	"for object in `IsPointOnEllipticCurve'",
	[IsPointOnEllipticCurve and IsPointOnEllipticCurveRep],
	function(point)
		if IsOne(point) then
			Print("infinite point");
		else
			Print(point!.coordinates);
		fi;
	end
);

#########################
### One as NE
#########################

InstallMethod(OneImmutable,
	"for an object in `IsEllipticCurve'",
	[IsEllipticCurve],
	101, # the prio is needed to beat the One method in lib/memory.gi
	function(G)
		return PointOnEllipticCurve([], G);
	end
);

InstallMethod(OneImmutable,
	"for an object in `IsPointOnEllipticCurve'",
	[IsPointOnEllipticCurve],
	function(p)
		return PointOnEllipticCurve([], p);
	end
);

# some function in the group library of GAP require
# an explicit OneMutable for elements of the group
InstallMethod(OneMutable,
	"for an object in `IsPointOnEllipticCurve'",
	[IsPointOnEllipticCurve],
	function(p)
		return OneImmutable(p);
	end
);

InstallMethod(IsOne,
	"for an object in `IsPointOnEllipticCurve'",
	[IsPointOnEllipticCurve],
	function(p)
		return p = One(p);
	end
);

#########################
### Operators on Points
#########################

InstallMethod(\=,
	"for object in `IsPointOnEllipticCurve'",
	IsIdenticalObj,
	[IsPointOnEllipticCurve and IsPointOnEllipticCurveRep, IsPointOnEllipticCurve and IsPointOnEllipticCurveRep],
	function(p, q)
		return p!.coordinates = q!.coordinates;
	end
);

InstallMethod(\<,
	"for object in `IsPointOnEllipticCurve'",
	IsIdenticalObj,
	[IsPointOnEllipticCurve and IsPointOnEllipticCurveRep, IsPointOnEllipticCurve and IsPointOnEllipticCurveRep],
	function(p, q)
		if IsOne(q) then
			return false;
		fi;
		if IsOne(p) then
			return true;
		fi;
		if p!.coordinates[1] = q!.coordinates[1] then
			return p!.coordinates[2] < q!.coordinates[2];
		fi;
		return p!.coordinates[1] < q!.coordinates[1];
	end
);

InstallMethod(\*,
	"for two objects in `IsPointOnEllipticCurve'",
	IsIdenticalObj,
	[IsPointOnEllipticCurve and IsPointOnEllipticCurveRep, IsPointOnEllipticCurve and IsPointOnEllipticCurveRep],
	function(p, q)
		local x1, x2, y1, y2, x3, y3, coeffs, l, v;
		if IsOne(p) then
			return q;
		fi;
		if IsOne(q) then
			return p;
		fi;
		x1 := p!.coordinates[1];
		y1 := p!.coordinates[2];
		x2 := q!.coordinates[1];
		y2 := q!.coordinates[2];
		coeffs := CollectionsFamily(FamilyObj(p))!.coefficients;
		if (x1 = x2) and IsZero(y1 + y2 + coeffs[1]*x1 + coeffs[3]) then
			return One(p);
		fi;
		if x1 = x2 then
			l := ( 3*x1^2 + 2*coeffs[2]*x1 + coeffs[4] - coeffs[1]*y1 )
				/ ( 2*y1 + coeffs[1]*x1 + coeffs[3] );
			v := ( -x1^3 + coeffs[4]*x1 + 2*coeffs[6] - coeffs[3]*y1 )
				/ ( 2*y1 + coeffs[1]*x1 + coeffs[3] );
		else
			l := ( y2 - y1 ) / ( x2 - x1 );
			v := ( y1*x2 - y2*x1 ) / ( x2 - x1 );
		fi;
		x3 := l^2 + coeffs[1]*l - coeffs[2] - x1 - x2;
		y3 := -(l+coeffs[1])*x3 - v - coeffs[3];
		return PointOnEllipticCurve( [x3, y3], p);
	end
);

InstallMethod(InverseOp,
	"for an object in `IsPointOnEllipticCurve'",
	[IsPointOnEllipticCurve and IsPointOnEllipticCurveRep],
	function(p)
		local x, y1, y2, coeffs;
		if IsOne(p) then
			return p;
		fi;
		x  := p!.coordinates[1];
		y1 := p!.coordinates[2];
		coeffs := CollectionsFamily(FamilyObj(p))!.coefficients;
		y2 := -(y1 + coeffs[1]*x + coeffs[3]);
		return PointOnEllipticCurve( [x, y2], p);
	end
);

InstallMethod(Enumerator,
	"for an object in `IsEllipticCurve'",
	[IsEllipticCurve],
	function(G)
		local field, definingEquation, poly, vars, res, x, y;
		field := FamilyObj(G)!.field;
		if not IsFinite(field) then
			TryNextMethod();
		fi;
		definingEquation := GetDefiningEquation(G);
		poly := definingEquation[1];
		vars := definingEquation[2];
		res := [ One(G) ];
		for x in field do
			for y in AsSet( RootsOfPolynomial( Value(poly, [vars[1]], [x]) )) do
				Append(res, [ PointOnEllipticCurve([x,y], G) ] );
			od;
		od;
		return res;
	end
);

InstallMethod(GeneratorsOfGroup,
	"for an object in `IsEllipticCurve'",
	[IsEllipticCurve],
	function(G)
		local elements, GByGenerators;
		elements := Elements(G);
		GByGenerators := Group(elements);
		UseIsomorphismRelation(G, GByGenerators);
		SetAsSSortedList(GByGenerators, elements);
		return SmallGeneratingSet(GByGenerators);
	end
);
