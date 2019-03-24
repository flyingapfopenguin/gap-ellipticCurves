
InstallMethod(RandomEllipticCurve,
	"for a field",
	[ IsField ],
	function(f)
		local coeffs;
		if Characteristic(f) in [2, 3] then
			repeat
				coeffs := [PseudoRandom(f), PseudoRandom(f), PseudoRandom(f), PseudoRandom(f), 0, PseudoRandom(f)];
			until (not IsZero(__ellpiticCurve__delta(coeffs)));
		else
			repeat
				coeffs := [0, 0, 0, PseudoRandom(f), 0, PseudoRandom(f)];
			until (not IsZero(__ellpiticCurve__delta(coeffs)));
		fi;
		return EllipticCurve(coeffs, f);
	end
);
