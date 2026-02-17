{
  pkgs,
  ...
}:

{
  services.xserver.xkb = {
    layout = "lea";

    extraLayouts.lea = {
      description = "LEA custom layout";
      languages = [ "eng" ];

      symbolsFile = pkgs.writeText "LEA" ''
        default partial alphanumeric_keys
        xkb_symbols "lea" {
            name[Group1]= "LEA";
            include "level3(ralt_switch)"

            key <TLDE> { [ backslash, bar, grave ] };
            key <AE01> { [ 1, exclam, exclam ] };
            key <AE02> { [ 2, quotedbl, at ] };
            key <AE03> { [ 3, numbersign, sterling ] };
            key <AE04> { [ 4, dollar, section ] };
            key <AE05> { [ 5, percent, degree ] };
            key <AE06> { [ bracketleft, braceleft, ordfeminine ] };
            key <AE07> { [ bracketright, braceright, asciicircum ] };
            key <AE08> { [ 6, asciicircum, asciitilde ] };
            key <AE09> { [ 7, ampersand ] };
            key <AE10> { [ 8, asterisk, bracketleft ] };
            key <AE11> { [ 9, parenleft, bracketright ] };
            key <AE12> { [ 0, parenright ] };

            key <AD01> { [ v, V ] };
            key <AD02> { [ m, M ] };
            key <AD03> { [ l, L ] };
            key <AD04> { [ c, C, ccedilla, Ccedilla ] };
            key <AD05> { [ p, P ] };
            key <AD06> { [ equal, plus ] };
            key <AD07> { [ slash, asterisk ] };
            key <AD08> { [ f, F, ocircumflex, Ocircumflex ] };
            key <AD09> { [ o, O, oacute, Oacute ] };
            key <AD10> { [ u, U, uacute, Uacute ] };
            key <AD11> { [ comma, semicolon ] };
            key <AD12> { [ quotedbl, exclam ] };
            key <BKSL> { [ numbersign, asciitilde ] };

            key <AC01> { [ s, S, atilde, Atilde ] };
            key <AC02> { [ t, T, acircumflex, Acircumflex ] };
            key <AC03> { [ r, R, agrave, Agrave ] };
            key <AC04> { [ d, D, aacute, Aacute ] };
            key <AC05> { [ y, Y ] };
            key <AC06> { [ less, greater ] };
            key <AC07> { [ q, Q ] };
            key <AC08> { [ n, N, otilde, Otilde ] };
            key <AC09> { [ e, E, eacute, Eacute ] };
            key <AC10> { [ i, I, iacute, Iacute ] };
            key <AC11> { [ a, A, aacute, Aacute ] };

            key <LSGT> { [ z, Z ] };
            key <AB01> { [ k, K ] };
            key <AB02> { [ x, X ] };
            key <AB03> { [ g, G ] };
            key <AB04> { [ w, W ] };
            key <AB05> { [ j, J ] };
            key <AB06> { [ minus, underscore, plus ] };
            key <AB07> { [ b, B, ecircumflex, Ecircumflex ] };
            key <AB08> { [ h, H, egrave, Egrave ] };
            key <AB09> { [ apostrophe, question ] };
            key <AB10> { [ period, colon ] };
        };
      '';
    };
  };
}
