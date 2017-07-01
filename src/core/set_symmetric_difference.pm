proto sub infix:<(^)>(|) is pure { * }
multi sub infix:<(^)>()               { set()  }
multi sub infix:<(^)>(QuantHash:D $a) { $a     } # Set/Bag/Mix
multi sub infix:<(^)>(SetHash:D $a)   { $a.Set }
multi sub infix:<(^)>(BagHash:D $a)   { $a.Bag }
multi sub infix:<(^)>(MixHash:D $a)   { $a.Mix }
multi sub infix:<(^)>(Any $a)         { $a.Set } # also for Iterable/Map

multi sub infix:<(^)>(Setty:D $a, Setty:D $b) {
    nqp::if(
      (my $araw := $a.raw_hash) && nqp::elems($araw),
      nqp::if(
        (my $braw := $b.raw_hash) && nqp::elems($braw),
        nqp::stmts(                            # both are initialized
          nqp::if(
            nqp::islt_i(nqp::elems($araw),nqp::elems($braw)),
            nqp::stmts(                        # $a smallest, iterate over it
              (my $iter  := nqp::iterator($araw)),
              (my $elems := nqp::clone($braw))
            ),
            nqp::stmts(                        # $b smallest, iterate over that
              ($iter  := nqp::iterator($braw)),
              ($elems := nqp::clone($araw))
            )
          ),
          nqp::while(
            $iter,
            nqp::if(                           # remove if in both
              nqp::existskey($elems,nqp::iterkey_s(nqp::shift($iter))),
              nqp::deletekey($elems,nqp::iterkey_s($iter)),
              nqp::bindkey($elems,nqp::iterkey_s($iter),nqp::iterval($iter))
            )
          ),
          nqp::create(Set).SET-SELF($elems)
        ),
        nqp::if(nqp::istype($a,Set),$a,$a.Set) # $b empty, so $a
      ),
      nqp::if(nqp::istype($b,Set),$b,$b.Set)   # $a empty, so $b
    )
}

multi sub infix:<(^)>(Mixy:D $a, Mixy:D $b) {
    nqp::if(
      (my $araw := $a.raw_hash) && nqp::elems($araw),
      nqp::if(
        (my $braw := $b.raw_hash) && nqp::elems($braw),
        nqp::stmts(                            # both are initialized
          nqp::if(
            nqp::islt_i(nqp::elems($araw),nqp::elems($braw)),
            nqp::stmts(                        # $a smallest, iterate over it
              (my $iter  := nqp::iterator(my $base := $araw)),
              (my $elems := nqp::clone($braw))
            ),
            nqp::stmts(                        # $b smallest, iterate over that
              ($iter  := nqp::iterator($base := $braw)),
              ($elems := nqp::clone($araw))
            )
          ),
          nqp::while(
            $iter,
            nqp::if(                           # remove if in both
              nqp::existskey($elems,nqp::iterkey_s(nqp::shift($iter))),
              nqp::if(
                (my $diff := nqp::getattr(nqp::iterval($iter),Pair,'$!value')
                  - nqp::getattr(
                      nqp::atkey($elems,nqp::iterkey_s($iter)),
                      Pair,
                      '$!value'
                    )
                ),
                nqp::bindkey(
                  $elems,
                  nqp::iterkey_s($iter),
                  nqp::p6bindattrinvres(
                    nqp::clone(nqp::iterval($iter)),Pair,'$!value',abs($diff)
                  )
                ),
                nqp::deletekey($elems,nqp::iterkey_s($iter))
              ),
              nqp::bindkey(
                $elems,
                nqp::iterkey_s($iter),
                nqp::clone(nqp::iterval($iter))
              )
            )
          ),
          nqp::create(Mix).SET-SELF($elems)
        ),
        nqp::if(nqp::istype($a,Mix),$a,$a.Mix) # $b empty, so $a
      ),
      nqp::if(nqp::istype($b,Mix),$b,$b.Mix)   # $a empty, so $b
    )
}

multi sub infix:<(^)>(Mixy:D $a, Baggy:D $b) { infix:<(^)>($a, $b.Mix) }
multi sub infix:<(^)>(Baggy:D $a, Mixy:D $b) { infix:<(^)>($a.Mix, $b) }
multi sub infix:<(^)>(Baggy:D $a, Baggy:D $b) {
    nqp::if(
      (my $araw := $a.raw_hash) && nqp::elems($araw),
      nqp::if(
        (my $braw := $b.raw_hash) && nqp::elems($braw),
        nqp::stmts(                            # both are initialized
          nqp::if(
            nqp::islt_i(nqp::elems($araw),nqp::elems($braw)),
            nqp::stmts(                        # $a smallest, iterate over it
              (my $iter  := nqp::iterator(my $base := $araw)),
              (my $elems := nqp::clone($braw))
            ),
            nqp::stmts(                        # $b smallest, iterate over that
              ($iter  := nqp::iterator($base := $braw)),
              ($elems := nqp::clone($araw))
            )
          ),
          nqp::while(
            $iter,
            nqp::if(                           # remove if in both
              nqp::existskey($elems,nqp::iterkey_s(nqp::shift($iter))),
              nqp::if(
                (my int $diff = nqp::sub_i(
                  nqp::getattr(nqp::iterval($iter),Pair,'$!value'),
                  nqp::getattr(
                    nqp::atkey($elems,nqp::iterkey_s($iter)),
                    Pair,
                    '$!value'
                  )
                )),
                nqp::bindkey(
                  $elems,
                  nqp::iterkey_s($iter),
                  nqp::p6bindattrinvres(
                    nqp::clone(nqp::iterval($iter)),
                    Pair,
                    '$!value',
                    nqp::abs_i($diff)
                  )
                ),
                nqp::deletekey($elems,nqp::iterkey_s($iter))
              ),
              nqp::bindkey($elems,nqp::iterkey_s($iter),nqp::iterval($iter))
            )
          ),
          nqp::create(Bag).SET-SELF($elems)
        ),
        nqp::if(nqp::istype($a,Bag),$a,$a.Bag) # $b empty, so $a
      ),
      nqp::if(nqp::istype($b,Bag),$b,$b.Bag)   # $a empty, so $b
    )
}

multi sub infix:<(^)>(Map:D $a, Map:D $b) {
    nqp::if(
      nqp::eqaddr($a.keyof,Str(Any)) && nqp::eqaddr($b.keyof,Str(Any)),
      nqp::if(                                    # both ordinary Str hashes
        (my $araw := nqp::getattr(nqp::decont($a),Map,'$!storage'))
          && nqp::elems($araw),
        nqp::if(                                  # $a has elems
          (my $braw := nqp::getattr(nqp::decont($b),Map,'$!storage'))
            && nqp::elems($braw),
          nqp::stmts(                             # $b also, need to check both
            (my $elems := nqp::create(Rakudo::Internals::IterationSet)),
            (my $iter := nqp::iterator($araw)),
            nqp::while(                           # check $a's keys in $b
              $iter,
              nqp::unless(
                nqp::existskey($braw,nqp::iterkey_s(nqp::shift($iter))),
                nqp::bindkey(
                  $elems,nqp::iterkey_s($iter).WHICH,nqp::iterkey_s($iter)
                )
              )
            ),
            ($iter := nqp::iterator($braw)),
            nqp::while(                           # check $b's keys in $a
              $iter,
              nqp::unless(
                nqp::existskey($araw,nqp::iterkey_s(nqp::shift($iter))),
                nqp::bindkey(
                  $elems,nqp::iterkey_s($iter).WHICH,nqp::iterkey_s($iter)
                )
              )
            ),
            nqp::create(Set).SET-SELF($elems)
          ),
          $a.Set                                  # no $b, so $a
        ),
        $b.Set                                    # no $a, so $b
      ),
      $a.Set (^) $b.Set                           # object hash(es), coerce!
    )
}

multi sub infix:<(^)>(Iterable:D $a, Iterable:D $b) {
    nqp::if(
      (my $aiterator := $a.flat.iterator).is-lazy
        || (my $biterator := $b.flat.iterator).is-lazy,
      Failure.new(X::Cannot::Lazy.new(:action('symmetric diff'),:what<set>)),
      nqp::stmts(
        (my $elems := Rakudo::QuantHash.ADD-PAIRS-TO-SET(
          nqp::create(Rakudo::Internals::IterationSet),
          $aiterator
        )),
        nqp::until(
          nqp::eqaddr((my $pulled := $biterator.pull-one),IterationEnd),
          nqp::if(
            nqp::existskey($elems,(my $WHICH := $pulled.WHICH)),
            nqp::deletekey($elems,$WHICH),
            nqp::bindkey($elems,$WHICH,$pulled)
          )
        ),
        nqp::create(Set).SET-SELF($elems)
      )
    )
}

multi sub infix:<(^)>(**@p) is pure {
    my $chain = @p.elems;

    if $chain == 1 {
        return @p[0];
    } elsif $chain == 2 {
        my ($a, $b) = @p;
        my $mixy-or-baggy = False;
        if nqp::istype($a, Mixy) || nqp::istype($b, Mixy) {
            ($a, $b) = $a.MixHash, $b.MixHash;
            $mixy-or-baggy = True;
        } elsif nqp::istype($a, Baggy) || nqp::istype($b, Baggy) {
            ($a, $b) = $a.BagHash, $b.BagHash;
            $mixy-or-baggy = True;
        }
        return  $mixy-or-baggy
                    # the set formula is not symmetric for bag/mix. this is.
                    ?? ($a (-) $b) (+) ($b (-) $a)
                    # set formula for the two-arg set.
                    !! ($a (|) $b) (-) ($b (&) $a);
    } else {
        if Rakudo::Internals.ANY_DEFINED_TYPE(@p,Baggy) {
            my $head;
            while (@p) {
                my ($a, $b);
                if $head.defined {
                    ($a, $b) = $head, @p.shift;
                } else {
                    ($a, $b) = @p.shift, @p.shift;
                }
                if nqp::istype($a, Mixy) || nqp::istype($b, Mixy) {
                    ($a, $b) = $a.MixHash, $b.MixHash;
                } elsif nqp::istype($a, Baggy) || nqp::istype($b, Baggy) {
                    ($a, $b) = $a.BagHash, $b.BagHash;
                }
                $head = ($a (-) $b) (+) ($b (-) $a);
            }
            return $head;
        } else {
            return ([(+)] @p>>.Bag).grep(*.value == 1).Set;
        }
    }
}
# U+2296 CIRCLED MINUS
only sub infix:<⊖>($a, $b) is pure {
    $a (^) $b;
}

# vim: ft=perl6 expandtab sw=4