import 'package:flutter/material.dart';


class ConsentPage extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ConsentPage({
    Key? key,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}


class _ConsentPageState extends State<ConsentPage> {
  static const String eulaText = '''Prezado(a) Colaborador(a), O aplicativo Vida Coletiva é um projeto da Universidade Federal Fluminense, desenvolvido pelo laboratório no.ar e o UFFlabs. Objetiva coletar registros dos colaboradores por meio de textos, áudios e imagens para impulsionar a construção compartilhada de conhecimento e preservação da memória social. Vida Coletiva usa gravações de áudio, imagens e conteúdo textual de colaboradores brasileiros para fins de pesquisa, extensão e memória social - que podem incluir, mas não estão limitados a: acesso público em páginas da UFF e canais de mídia social da UFF. Esses materiais serão usados pelos pesquisadores para fins acadêmicos e de interesse público, podendo ser revogados pelos colaboradores a qualquer momento, e serão compartilhados com terceiros de forma anonimizada, até os prazos previstos em lei. Não serão compartilhados os dados pessoais com ninguém, de dentro ou fora da Universidade, a menos que seja fundamental para a execução do serviço a ser prestado ou seja obrigatório seu compartilhamento para os casos previstos pela Lei Geral de Proteção de Dados - LGPD (Lei nº 13.709/2018). Por compartilhamento, entende-se: conceder acesso a bancos de dados, enviar e-mails com dados pessoais para qualquer pessoa, tramitar documentos físicos ou deixá-los acessíveis sem procedimentos de segurança. A Política de Privacidade do aplicativo Vida Coletiva segue as diretrizes da LGPD; o inciso X do art. 5º da CF; e os Princípios da Iniciativa de Rede Global (GNI) sobre Liberdade de Expressão e Privacidade (https://globalnetworkinitiative.org/gni-principles/), “Salvo se autorizadas, ou se necessárias à administração da justiça ou à manutenção da ordem pública, a divulgação de escritos, a transmissão da palavra, ou a publicação, a exposição ou a utilização da imagem de uma pessoa poderão ser proibidas, a seu requerimento e sem prejuízo da indenização que couber, se lhe atingirem a honra, a boa fama ou a respeitabilidade, ou se se destinarem a fins comerciais” art. 20 do CCB. Para obter informações sobre como lidamos com dados pessoais, leia nossa Declaração de Privacidade; Proteção de Dados Pessoais; e Comitê de Ética da UFF (Resolução CNS/MS nº 510, de 07 de abril de 2016 – Trata sobre especificidade da análise ética de pesquisas na área de ciências humanas e sociais; Norma Operacional 001/2013 – Dispõe sobre a organização e funcionamento do Sistema CEP/CONEP e sobre os procedimentos para submissão, avaliação e acompanhamento de pesquisa envolvendo seres humanos no Brasil). Se o(a) colaborador(a) desejar exercer algum dos seus direitos, deverá entrar em contato com o nosso Encarregado de Dados pelo endereço de e-mail: projetorelatoscotidianos.coc.esr@id.uff.br. Para atualizar seus dados ou solicitar o descadastramento do nosso banco de dados, deve-se preencher formulário específico, descrevendo a motivação. Tem-se a possibilidade de pedirmos mais informações ou provas para verificar a identidade do(a) usuário(a) antes de prosseguirmos com o pedido. O tempo máximo de resposta completa aos questionamentos d@ usuário(a), sobre o uso de seus dados pessoais pela Vida Coletiva, é de 15 (QUINZE) dias úteis, de acordo com o art. 19 da LGPD. A segurança dos dados armazenados na nossa base é garantida por meio do acesso restrito às pessoas autorizadas do Vida Coletiva, mediante termo de confidencialidade, cujas senhas de acesso são alteradas periodicamente. (Acrescentar link da STI?) Ficaríamos muito gratos se você pudesse contribuir com o Projeto, permitindo usar as imagens, os áudios e textos para os fins descritos acima. ATENÇÃO! O Vida Coletiva não solicita dados pessoais de qualquer natureza via WhatsApp ou ligação telefônica. Todos os dados são coletados por formulário eletrônico ou por e-mail institucional. Confirmo que: 1. Eu concedo ao projeto Vida Coletiva da UFF, uma licença exclusiva, sub licenciável consentimento e licença para usar, reproduzir e publicar todos e quaisquer direitos de imagem em qualquer meio/mídia em conexão com os propósitos juntamente com o direito do aplicativo Vida Coletiva autorizar outros a fazê-lo. 2. Eu atribuo e transfiro para o Vida Coletiva, direitos autorais passados, presentes e futuros, quaisquer direitos dos colaboradores em relação a isso e/ou quaisquer imagens estáticas, citações ou trechos de som extraídos, copiados ou adaptados dos materiais. Esses direitos, no entanto, podem ser anulados, se estiverem sob os critérios de exceção previstos pela LGPD. 3. Entendo que os materiais podem ser usados em seu formato original ou editados. Isso inclui, mas não se limita a, produzir transcrições ou que acompanhem as descrições escritas dos materiais. 4. Entendo que os materiais continuarão sendo de responsabilidade do Vida Coletiva, sempre com a anuência do autor original e podem ser usados em suas publicações, sites e outros meios de publicidade material, e autoriza-se expressamente tal uso. 5. Entendo que os materiais serão mantidos de acordo com os regulamentos de proteção de dados pessoais relevantes. Não me oponho que o Vida Coletiva transfira os materiais e/ou armazene-os para fins de pesquisa, ensino e preservação da memória social.''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termo de Consentimento')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  eulaText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.onDecline,
                  child: const Text('Recusar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmação'),
                        content: const Text('Você concorda com os termos apresentados?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Não'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sim'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      widget.onAccept();
                    }
                  },
                  child: const Text('Aceitar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
