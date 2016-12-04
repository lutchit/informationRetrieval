package parser;

use strict ;
no strict 'refs';
use XML::LibXML;
use encoding 'utf8';



BEGIN {}
 sub parsing {
my ($repcoll) = "coll"; # r�pertoire ne contenant que des fichiers XXXXX.xml
my ($parser) = XML::LibXML->new('recover'=>1);
$parser->recover_silently(1); # pour �viter que le parser plante si erreur XML

# comptages
my ($nb_articles) = 0;
my ($nb_elements) = 0;
my ($taille_texte) = 0;

my %hashwords = ();

# limites
my ($nb_todo) = 100;
my (%balises_ok) = ('bdy'=>1, 'sec'=>1, 'title'=>1);

# on ouvre le r�pertoire de la collection
opendir(REPIN, $repcoll) || die "Erreur ouverture !\n";
my ($entry);
while ($entry = readdir(REPIN)) {
	print "ENTRY : $entry\n";
    if (! ($entry =~ /^\.\.?$/)) {
	# Si le nom de fichier ne commence pas par ".", c'est donc un fichier XML
	$nb_articles ++;
	if (!($nb_articles % 100)) { # Une trace
	    # print "Nombre d'articles : $nb_articles\n";
	}
	# On parse le fichier XML
	my ($tree) = $parser->parse_file( "$repcoll/$entry" );
	if ($tree) {
	    # on r�cup�re la racine
	    my $root = $tree->getDocumentElement;
	    if ($root) {
			# on cherche un �l�ment "titre"
			my ($titre) = $root->findvalue('//title');
			$titre =~ s/\s+/ /g;
			$nb_elements ++;
			# print "titre : $titre\n";
			# on r�cup�re le num�ro de document
			my $nodoc = $root->getElementsByTagName('id')->[0]->getFirstChild->getData;
			# print "nodoc : $nodoc\n";

			my $body = $root->findnodes('//bdy');

			$body =~ s/\n/ /sg;
			$body =~ s/ +/ /sg;
			# $body =~ s/\W+//sg;
			#$body =~ s/[^\pL\s]//g;
			$body =~ tr/a-zA-Z0-9 //dc;
			# $body =~ s/\;//sg;
			# $body =~ s/\,//sg;
			# $body =~ s/\'//sg;
			# $body =~ s/\"//sg;
			# $body =~ s/\(//sg;
			# $body =~ s/\)//sg;
			# $body =~ s/\-//sg;
			# $body =~ s/\_//sg;
			# $body =~ s/\^//sg;
			# $body =~ s/\://sg;
			# $body =~ s/\///sg;

			#print "body : $body\n\n";

			# on r�cup�re le texte de tout l'article
			my ($texte) = $root->textContent;

			#chomp($texte);
			#$texte =~ s/\n\n\/\n/g;

			#print "texte : $texte\n";
			my @mots = split(" ", $body);

			foreach my $mot (@mots) {
				if (!exists($hashwords{$mot})) {
					#print "mot1 : $mot\n";
					my %hashtf = ();
					$hashtf{$nodoc} = 1;
					$hashwords{$mot} = \%hashtf;
				} else {
					#print "mot2 : $mot\n";
					$hashwords{$mot}{$nodoc}++;
				}
				#print "$mot | ";
			}

			# print "Nb occurence of 'the' in $nodoc : $hashwords{the}{$nodoc}\n";

			$taille_texte += length($texte);
			my ($chemin) = '/article[1]';
			my (%num_balises);
			# on parcours les fils de la racine
			foreach my $node ($root->childNodes()) {
			    my ($tag) = $node->nodeName();
			    if ($balises_ok{$tag}) {
					$nb_elements ++;
					$num_balises{$tag}++;
					# print "$entry$chemin/$tag\[$num_balises{$tag}\] : $titre\n";
			    }
			}
	    } else {
			print "Erreur title parser (fichier $repcoll/$entry\n";
	    }
	} else {
	    print "Erreur parser (fichier $repcoll/$entry\n";
	}
	#  last if ($nb_articles == $nb_todo);
    }
}

# foreach my $k (sort keys(%hashwords)) {
# 	print "Clef=$k Valeur=$hashwords{$k}\n";
# }
# print "TEST : $hashwords{the}\n";
# my %hash2 = $hashwords{the};
# print "\n\n";
# foreach my $k (sort keys(%hash2)) {
# 	print "Clef=$k Valeur=$hash2{$k}\n";
# }

print "nb words : ".scalar(keys (%hashwords))."\n";

print "Nombre d'articles : $nb_articles
Nombre d'elements : $nb_elements
Taille totale texte : $taille_texte\n";
  return %hashwords;
}
1;
