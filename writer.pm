package writer;
use strict;

sub writeRuns {
my $nb_run = shift;
my $algo = shift;

my @list = @_;
my $compteur = 0;
my $req = 1;
my $score = 1501;

my $list_size = scalar(@list);
print $list_size;

my $title = "PierreJulienDimitriLudovic_03_" . $nb_run . "_" . $algo . "_articles.txt";

open (FICHIER, ">".$title) || die ("Vous ne pouvez pas créer le fichier \"fichier.txt\"");
# On écrit dans le fichier...*
foreach (@list){

  $compteur++;
  $score--;
  if ($compteur > 1500){
    $req++;
    $compteur = $compteur - 1500;
    $score = $score + 1500;
  }

  my $nb_req = req($req);

  print FICHIER "$nb_req Q0 " . $_ . " " . $compteur . " " . $score . " PierreJulienDimitriLudovic /article[1]\n";
}

close (FICHIER);

}

sub req{
  my $nb = shift;
  my $ret;
  if($nb == 1) {$ret = 2009011;}
  if($nb == 2) {$ret = 2009036;}
  if($nb == 3) {$ret = 2009067;}
  if($nb == 4) {$ret = 2009073;}
  if($nb == 5) {$ret = 2009074;}
  if($nb == 6) {$ret = 2009078;}
  if($nb == 7) {$ret = 2009085;}
  return $ret;
}
1;
