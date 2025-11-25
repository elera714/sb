// C3 - RET - Near return to calling procedure
// CB - RET - Far return to calling procedure
else if(IslenenKomut = $C3) then
begin

  D21 := YigindanAl(DU2);
  {$IFDEF DEBUG} mmCikti.Lines.Add('ret (yakın) %.4d', [SmallInt(D21)]); {$ENDIF}
  YZMC_DEGERSN[YZMC0_EIP] := D21;
end
