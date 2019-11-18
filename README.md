# scanflash

Script para a enumeração de diretórios e subdomínios usando o GNU Parallel.

  - Busca de diretórios
  - Busca de subdomínios
  - Robots.txt parser
  - Wordlist.txt personalizada


O que é GNU Parallel?

O [GNU Parallel](https://www.gnu.org/software/parallel/) é um utilitário orientado por linha de comando para Linux e outros sistemas operacionais semelhantes ao Unix que permite ao usuário executar scripts ou comandos de shell em paralelo. O GNU Parallel é um software livre, escrito por Ole Tange em Perl. Está disponível sob os termos da GPLv3.


### Instalação

Instalando o parallel:

```sh
$ sudo apt-get update
$ sudo apt-get install parallel
```

### Argumentos


| Args | Default | Required |
| ------ | ------ | ------  |
| -t, --target | None | Yes |
| -p, --path | wordlist.txt | No |
| -s, --sub | False | No |
| -r, --robots | False | No |
| -f, --file | None | No |
| -h, --help | False | No |
| -v, --version | False | No |


### Exemplos

Buscando diretórios, subdomínios e diretórios no robots.txt usando uma wordlist personalizada:
```sh
$./scanflash -t exemplo.com -f /home/user/my_wordlist.txt -psr
```

Buscando apenas por subdomínios usando a wordlist.txt padrão:
```sh
$./scanflash -t exemplo.com -s
```

Buscando apenas por diretórios usando uma wordlist personalizada:
```sh
$./scanflash -t exemplo.com -f /home/user/my_wordlist.txt -p
```

Buscando por diretórios no robots.txt usando a wordlist.txt padrão:
```sh
$./scanflash -t exemplo.com -r
```

Mostrando a ajuda:
```sh
$./scanflash -h
```

### Screenshot

[![Scanflash](https://i.imgur.com/nDGXCEX.png)](https://github.com/brunomcuesta/scanflash/)

