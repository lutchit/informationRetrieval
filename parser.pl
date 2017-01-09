#!/usr/bin/perl
use strict ;
no strict 'refs';
use XML::LibXML;
use encoding 'utf8';


BEGIN {}


my ($repcoll) = "coll"; # répertoire ne contenant que des fichiers XXXXX.xml
my ($parser) = XML::LibXML->new('recover'=>1);
$parser->recover_silently(1); # pour éviter que le parser plante si erreur XML

# comptages
my ($nb_articles) = 0;
my ($nb_elements) = 0;
my ($taille_texte) = 0;

my %hashwords = ();
my @stopwords = ("a", "about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also","although","always","am","among", "amongst", "amoungst", "amount",  "an", "and", "another", "any","anyhow","anyone","anything","anyway", "anywhere", "are", "around", "as",  "at", "back","be","became", "because","become","becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom","but", "by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each", "eg", "eight", "either", "eleven","else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own","part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves", "the");



# limites
my ($nb_todo) = 1;
my (%balises_ok) = ('bdy'=>1, 'sec'=>1, 'title'=>1);

# on ouvre le répertoire de la collection
opendir(REPIN, $repcoll) || die "Erreur ouverture !\n";
my ($entry);
while ($entry = readdir(REPIN)) {
	print "ENTRY : $entry\n";
    if (! ($entry =~ /^\.\.?$/)) {
	# Si le nom de fichier ne commence pas par ".", c'est donc un fichier XML
	$nb_articles ++;
	if (!($nb_articles % 100)) { # Une trace
	    print "Nombre d'articles : $nb_articles\n";
	}
	# On parse le fichier XML
	my ($tree) = $parser->parse_file( "$repcoll/$entry" );
	if ($tree) {
			#print "treeee -> $tree\n";
	    # on récupère la racine
	    my $root = $tree->getDocumentElement;
	    #print "roooot -> $root\n";
	    if ($root) {
			# on cherche un élément "titre"
			my ($titre) = $root->findvalue('//title');

			$titre =~ s/\s+/ /g;
			$nb_elements ++;
			print "titre : $titre\n";
			# on récupère le numéro de document
			my $nodoc = $root->getElementsByTagName('id')->[0]->getFirstChild->getData;
			print "nodoc : $nodoc\n";


			# for my $sample ($root->findnodes('//bdy')) {
   #  		for my $property ($sample->findnodes('./*')) {
   #      	print $property->nodePath(), " ======> ", $property->textContent(), "\n";
   #  		}
   #  		print "\n";
			# }	

			my $nodes = $root->findnodes('//sec');
			foreach my $node ($nodes->get_nodelist) {
					#printf "%s --> %s\n", $node->nodePath, $node->textContent;
					my $docPath = $nodoc.$node->nodePath;
					my $nodeContent = $node->textContent;

					print "PATH =======> $docPath\n";

					$nodeContent =~ s/\n/ /sg;
					$nodeContent =~ s/ +/ /sg;
					$nodeContent =~ tr/a-zA-Z0-9 //dc;

					print "CONTENT =======> $nodeContent\n";

					my @mots = split(" ", $nodeContent);

					foreach my $mot (@mots) {
						if (!($mot ~~ @stopwords)) {
							if (!exists($hashwords{$mot})) {
								my %hashtf = ();
								$hashtf{$docPath} = 1;
								$hashwords{$mot} = \%hashtf;
							} else {
								if (exists($hashwords{$mot}{$docPath})) {
									$hashwords{$mot}{$docPath}++;
								}
								else {
									$hashwords{$mot}{$docPath} = 1;
								}
							}
							# print "$mot | ";
							# my $pathTest = "\/article\/entity\/bdy\/sec[1]";
							# print "Nb occurence of 'an' in $pathTest : $hashwords{an}{$pathTest}\n";
							# print "TEST :: $hashwords{$mot}{$nodePath}\n";
						}
					}
			}
			print "\n\n\n";

			#print "$hashwords{is}{\/article\/entity\/bdy\/sec[3]\/p[2]}\n";


			# my $body = $root->findnodes('//bdy');
			# #print "BODY : $body\n\n";
			# #my $nodeB = $body->childNodes();
			# #my ($pathB) = $nodeB->nodePath();
			# #print "PATHB --> $pathB\n";

			# my $n = $root->findnodes('//link')->shift;
			# say $n->nodePath;


			# $body =~ s/\n/ /sg;
			# $body =~ s/ +/ /sg;
			# # $body =~ s/\W+//sg;
			# #$body =~ s/[^\pL\s]//g;
			# $body =~ tr/a-zA-Z0-9 //dc;
			# # $body =~ s/\;//sg;
			# # $body =~ s/\,//sg;
			# # $body =~ s/\'//sg;
			# # $body =~ s/\"//sg;
			# # $body =~ s/\(//sg;
			# # $body =~ s/\)//sg;
			# # $body =~ s/\-//sg;
			# # $body =~ s/\_//sg;
			# # $body =~ s/\^//sg;
			# # $body =~ s/\://sg;
			# # $body =~ s/\///sg;

			# #print "body : $body\n\n";

			# on récupère le texte de tout l'article
			my ($texte) = $root->textContent;

			#chomp($texte);
			#$texte =~ s/\n\n\/\n/g;

			#print "texte : $texte\n";
			#my @mots = split(" ", $body);

			# foreach my $mot (@mots) {
			# 	if (!exists($hashwords{$mot})) {
			# 		#print "mot1 : $mot\n";
			# 		my %hashtf = ();
			# 		$hashtf{$nodoc} = 1;
			# 		$hashwords{$mot} = \%hashtf;
			# 	} else {
			# 		#print "mot2 : $mot\n";					
			# 		$hashwords{$mot}{$nodoc}++;
			# 	}
			# 	#print "$mot | ";
			# }

			my $pathTest = "$nodoc\/article\/entity\/bdy\/sec[3]";
			print "Nb occurence of 'is' in $pathTest : $hashwords{is}{$pathTest}\n";
			
			$taille_texte += length($texte);
			my ($chemin) = '/article[1]';
			#print "CHEMIN -> $chemin\n";
			my (%num_balises);
			#print "NUM_BALISES -> $num_balises\n";
			# on parcours les fils de la racine
			foreach my $node ($root->childNodes()) {
				#print "NODE ---> $node\n";
					#my ($path) = $node->nodePath();
					#print "PATH --> $path\n";
			    my ($tag) = $node->nodeName();
			    #print "TAG --> $tag\n";
			    if ($balises_ok{$tag}) {
					$nb_elements ++;
					$num_balises{$tag}++;
					#print "$entry$chemin/$tag\[$num_balises{$tag}\] : $titre\n";
			    }
			}
	    } else {
			print "Erreur title parser (fichier $repcoll/$entry\n";
	    }
	} else {
	    print "Erreur parser (fichier $repcoll/$entry\n";
	}
	last if ($nb_articles == $nb_todo);
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
