// 87 /r XCHG r/m16,r16 Exchange r16 with word from r/m16
// 87 /r XCHG r16,r/m16 Exchange word from r/m16 with r16
// 87 /r XCHG r/m32,r32 Exchange r32 with doubleword from r/m32
// 87 /r XCHG r32,r/m32 Exchange doubleword from r/m32 with r32
else if(Komut = $87) and ((Komut2 and %11000000) = %11000000) then
begin

  D41 := MYB16[(Komut2 and %00000111)];           // hedef yazmaç (1. parametre)
  D42 := MYB16[(Komut2 and %00111000) shr 3];     // kaynak yazmaç (2. parametre)
  D43 := YazmacDegerAl(D41);
  D44 := YazmacDegerAl(D42);

  YazmacDegistir(D41, D44);
  YazmacDegistir(D42, D43);

  {$IFDEF DEBUG} mmCikti.Lines.Add('xchg %s,%s', [Yazmaclar16[D41 and $F], Yazmaclar16[D42 and $F]]); {$ENDIF}
  IPDegeriniArtir(2);
end
