# Legado da parte 1 — persistência em SQLite

Esta pasta guarda o mecanismo de persistência local entregue na **primeira parte** do projeto,
preservado apenas para consulta. **Nada aqui é compilado nem referenciado pelo aplicativo atual**:
a pasta está fora de `lib/` e excluída do analisador em `analysis_options.yaml`.

Na segunda parte, a especificação passou a exigir o Firestore como banco remoto e proibiu
SQLite como mecanismo principal de persistência (§2), além de dividir a entidade `Aluno` em
`Pessoa` (dados cadastrais) e `Avaliacao` (as 15 notas). Por isso estes arquivos não têm mais
equivalente direto no código novo.

| Arquivo | Papel na parte 1 |
|---|---|
| `core/database/app_database.dart` | Abertura do banco, criação da tabela `alunos` e migrações |
| `data/services/aluno_local_storage_interface.dart` | Contrato da camada de service |
| `data/services/aluno_sqlite_service_impl.dart` | CRUD em SQLite, com os 15 critérios serializados em JSON numa coluna |
| `domain/models/aluno.dart` | Entidade única, com os critérios embutidos |
| `domain/models/aluno_mapper.dart` | Conversão entidade ↔ mapa |

Os imports relativos destes arquivos apontam para caminhos que existiam quando eles moravam em
`lib/`, então eles não resolvem mais a partir daqui. Para ver a parte 1 completa e funcionando,
use o histórico do git:

```bash
git show 7efd7e0 --stat        # último commit da parte 1
git checkout 7efd7e0 -- fama_if/lib   # restaura a lib inteira daquele momento
```
