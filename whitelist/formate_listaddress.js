import fs from 'fs';

const inputFile = './whitelist/adresses.txt';
const outputFile = './whitelist/adresses_modifiees.txt';

fs.readFile(inputFile, 'utf8', (err, data) => {
  if (err) {
    console.error('Erreur lors de la lecture du fichier:', err);
    return;
  }

  const adresses = data
    .trim()
    .split('\n')
    .map(adresse => adresse.replace(/["\s,]/g, ''))
    .filter(adresse => /^0x[a-fA-F0-9]{40}$/.test(adresse));

  if (adresses.length === 0) {
    console.error('Aucune adresse Ethereum valide trouvée dans le fichier.');
    return;
  }

  const adressesModifiees = adresses.map((adresse, index) => {
    const suffix = index < adresses.length - 1 ? ',' : '';
    return `"${adresse}"${suffix}`;
  });

  const resultat = adressesModifiees.join('\n');

  fs.writeFile(outputFile, resultat, 'utf8', (err) => {
    if (err) {
      console.error('Erreur lors de l\'écriture du fichier:', err);
      return;
    }
    console.log('Fichier modifié avec succès !');
  });
});
