
DeclareCategory("IsEllipticCurveEndomorphismRing", IsRingWithOne );
DeclareOperation("EllipticCurveEndomorphismRing", [ IsEllipticCurve ]);

DeclareCategory("IsEllipticCurveEndomorphism", IsAdditiveElementWithInverse and IsAdditivelyCommutativeElement and IsAssociativeElement and IsMapping);
DeclareCategoryCollections("IsEllipticCurveEndomorphism");
DeclareRepresentation("IsEllipticCurveEndomorphismRep", IsComponentObjectRep, ["R", "S"]);
DeclareOperation("EllipticCurveEndomorphism", [ IsEllipticCurveEndomorphismRing, IsUnivariateRationalFunction, IsUnivariateRationalFunction ]);
DeclareOperation("EllipticCurveEndomorphism", [ IsEllipticCurve, IsUnivariateRationalFunction, IsUnivariateRationalFunction ]);
DeclareOperation("EllipticCurveEndomorphism", [ IsEllipticCurve, IsInt ]);

DeclareOperation("Degree", [ IsEllipticCurveEndomorphism and IsEllipticCurveEndomorphismRep ]);
