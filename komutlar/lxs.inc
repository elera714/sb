// C5 /r - LDS r16,m16:16 - Load DS:r16 with far pointer from memory
else if(Komut = $C5) then
begin

  if((Komut2 and %11000000) = %00000000) then
  begin

    D41 := (Komut2 and %111);
    D42 := Mod00Isle(D41);

    D43 := MYB16[(Komut2 and %00111000) shr 3];     // 1. hedef yazmaç
    D44 := PWord(@Bellek144MB[D42 + 0])^;
    YazmacDegistir(D43, D44);
    D44 := PWord(@Bellek144MB[D42 + 2])^;
    YazmacDegistir(YZMC_DS, D44);

    {$IFDEF DEBUG} mmCikti.Lines.Add('lds %s,%s', [Yazmaclar16[D43 and $F], Bellekler00[D41]]); {$ENDIF}
    IPDegeriniArtir(2);
  end;
end
