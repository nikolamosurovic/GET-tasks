#!/bin/bash

# Proveriti da li fajl prilog.txt postoji
if [[ ! -f prilog.txt ]]; then
    echo "Greska: prilog.txt nije pronadjen!"
    exit 1
fi

# Kreiranje direktorijuma ako ne postoje
kreiraj_direktorijum() {
    lokacija="$1"
    [[ ! -d "$lokacija" ]] && mkdir -p "$lokacija"
}

# Validacija formata fajlova
regex="^k[0-9a-fA-F]{8}\.kod$"

# Obrada fajlova iz prilog.txt
while IFS= read -r fajl; do
    fajl=$(echo "$fajl" | sed 's/\r//')

    # Provera formata fajla
    if [[ $fajl =~ $regex ]]; then
        touch "$fajl"

        # Ekstrakcija delova iz naziva fajla
        hex_kod="${fajl:1:8}"
        G="${hex_kod:6:1}"
        E="${hex_kod:4:1}"

        # Odredjivanje lokacije
        if (( 0x$G % 2 == 0 )); then
            destinacija="$G"0/"$E"0
        else
            X=$(printf "%x" $((0x$G - 1)))
            destinacija="$X"0/"$E"0
        fi

        # Kreiranje direktorijuma i premestanje fajla
        kreiraj_direktorijum "$destinacija"
        mv "$fajl" "$destinacija/"
    else
        echo "$fajl" >> invalid_files.log
    fi

done < prilog.txt

echo "Obrada zavrsena. Proverite invalid_files.log za nevalidne fajlove."

