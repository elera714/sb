// CF - IRET - Interrupt return (16-bit operand size)
// CF - IRETD - Interrupt return (32-bit operand size)
{ TODO - IRETD uygulanacak }
else if(IslenenKomut = $CF) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('iret'); {$ENDIF}
  IPDegeriniArtir;

  D21 := YigindanAl(DU2);
  YZMC_DEGERSN[YZMC0_EIP] := D21;
  D21 := YigindanAl(DU2);
  YZMC_DEGERSN[YZMC0_CS] := D21;
  D21 := YigindanAl(DU2);
  Bayraklar := D21;
end
