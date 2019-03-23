#
# ellipticCurves: A library for ellitpic curves in GAP.
#
#! @Chapter Introduction
#!
#! ellipticCurves is a package which does some
#! interesting and cool things
#!
#! @Chapter Functionality
#!
#!
#! @Section Example Methods
#!
#! This section will describe the example
#! methods of ellipticCurves

#! @Description
#!   Insert documentation for your function here

DeclareGlobalFunction("__ellpiticCurve__delta");
DeclareGlobalFunction("__ellpiticCurve__AreCoordsOnCurve");

DeclareCategory("IsEllipticCurve", IsGroup and IsAbelian);
DeclareOperation("EllipticCurve", [ IsDenseList, IsField ]);
DeclareProperty("IsInShortWeierstrassForm", IsEllipticCurve);
DeclareAttribute("Discriminant", IsEllipticCurve);
DeclareOperation("AreCoordinatesOnCurve", [ IsDenseList, IsEllipticCurve ]);
DeclareOperation("GetDefiningEquation", [ IsEllipticCurve ]);

DeclareCategory("IsPointOnEllipticCurve", IsCommutativeElement and IsAssociativeElement and IsMultiplicativeElementWithInverse and CanEasilyCompareElements);
DeclareCategoryCollections("IsPointOnEllipticCurve");
InstallTrueMethod(IsGeneratorsOfMagmaWithInverses, IsPointOnEllipticCurveCollection);
DeclareRepresentation("IsPointOnEllipticCurveRep", IsComponentObjectRep, ["coordinates"]);
DeclareOperation("PointOnEllipticCurve", [ IsDenseList, IsFamily ]);
DeclareOperation("PointOnEllipticCurve", [ IsDenseList, IsEllipticCurve ]);
DeclareOperation("PointOnEllipticCurve", [ IsDenseList, IsPointOnEllipticCurve ]);
