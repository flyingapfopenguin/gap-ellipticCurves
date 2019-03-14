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

DeclareCategory("IsEllipticCurve", IsGroup and IsAbelian);
DeclareGlobalFunction("EllipticCurve");
DeclareProperty("IsInShortWeierstrassForm", IsEllipticCurve);

DeclareCategory("IsPointOnEllipticCurve", IsCommutativeElement and IsAssociativeElement and IsMultiplicativeElementWithInverse and CanEasilyCompareElements);
DeclareCategoryCollections("IsPointOnEllipticCurve");
InstallTrueMethod(IsGeneratorsOfMagmaWithInverses, IsPointOnEllipticCurveCollection);
DeclareRepresentation("IsPointOnEllipticCurveRep", IsComponentObjectRep, ["coordinates"]);
DeclareGlobalFunction("PointOnEllipticCurve");
