{ ... }:

{
  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        # Explicitly targets your laptop keyboard
        devices = [
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];

        extraDefCfg = ''
          process-unmapped-keys yes
        '';

        config = ''
          (defsrc
            tab  caps
            q    w    e    r    t    y    u    i    o    p
            a    s    d    f    g    h    j    k    l    ;
            z    x    c    v    b    n    m
            spc
          )

          (defalias
            ;; --- SYSTEM ---
            cap (tap-hold 200 200 esc lctl)
            spc (tap-hold-release 200 200 spc (layer-toggle my_symbols))
            tcap caps 

            ;; --- SYMBOLS (Left Hand) ---
            lt   h
            gt   S-h
            lpr  S-min
            rpr  S-eql
            lbkt 6
            rbkt 7
            lbrc S-6
            rbrc S-7
            pipe S-grv
            
            ;; --- DELETE ACTIONS ---
            dbsp (macro C-bspc)
            dln  (macro S-home bspc)

            ;; --- LOGIC FOR 'G' KEY ---
            del_logic (tap-hold 200 500 @dbsp @dln)

            ;; --- PROGRAMMING MACROS ---
            m_ne (macro spc S-1 y y spc)
            m_ee (macro spc y y y spc)
            m_ar (macro y S-h)
            m_an (macro spc S-9 S-9 spc)
            m_or (macro spc S-grv S-grv spc)

            ;; --- NAVIGATION (Right Hand) ---
            nlft left
            ndwn down
            nup  up
            nrgt right
          )

          (deflayer base
            tab  @cap
            q    w    e    r    t    y    u    i    o    p
            a    s    d    f    g    h    j    k    l    ;
            z    x    c    v    b    n    m
            @spc
          )

          (deflayer my_symbols
            C-tab  @tcap
            @m_ne @m_ee @lbkt @rbkt @pipe   _         _         @m_ar @m_an @m_or
            @lt   @gt   @lpr  @rpr  @del_logic _         @nlft @ndwn @nup  @nrgt
            _     _     @lbrc @rbrc _           _         _
            _
          )
        '';
      };
    };
  };
}
