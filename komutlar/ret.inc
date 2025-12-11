// C3 - RET - Near return to calling procedure
else if(Komut = $C3) then
begin

  D21 := YigindanAl(DU2);
  YZMC_DEGERSN[YZMC0_EIP] := D21;
  YazmacDegistir(YZMC_IP, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('ret %.4d', [SmallInt(D21)]); {$ENDIF}
end
// CB - RET - Far return to calling procedure
else if(Komut = $CB) then
begin

  D22 := YigindanAl(DU2);
  YZMC_DEGERSN[YZMC0_EIP] := D22;
  D21 := YigindanAl(DU2);
  YZMC_DEGERSN[YZMC0_CS] := D21;

  YazmacDegistir(YZMC_CS, D21);
  YazmacDegistir(YZMC_IP, D22);
  {$IFDEF DEBUG} mmCikti.Lines.Add('ret $%.4d:$%.4d', [D21, D22]); {$ENDIF}
end
