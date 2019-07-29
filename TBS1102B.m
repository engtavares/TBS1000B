%% Aquisi��o de dados para Oscilosc�pios tektronix 1000B
%   Criado por Gustavo R. Tavares - gustavotavares92@hotmail.com
%
%este programa l� e armazena as formas de onda dos oscilosc�pios da familia
%1000B da Tektronix. As leituras n�o s�o continuas, devido as limita��es do
%equipamento, cada medida leva em torno de 1,3s e demora outros 1,3s para
%fazer a proxima aquisi��o da dados, ou seja, o programa faz uma aquisi��o
%de sinal a cada 3s, como se um operador estivesse pressionando o bot�o de
%salvar dados no oscilosc�pio manualmente.

%%  dicas
% se o programa apresentar erros consecutivos, v� ao instrument control
% toolbox e delete todos os intrument objects

% na primeira vez que voc� for utilizar este programa, abra o instrument
% control toolbox e, com o oscilosc�pio ligado ao USB, fa�a um scan de VISA
% hardware para encontrar o VISA USB identifier. No meu computador o identificador
% �: "USB0::0x0699  ::0x0368::C032206::0::INSTR", mas nem sempre ser� o
% mesmo e por isso precisa ser alterado na sec��o de "Instrument
% Connection". O mesmo vale para o driver do oscilosc�pio, selecione um
% driver que permita o funcionamento completo do seu equipamento e altere o
% campo "deviceObj" dentro da sec��o "Instrument Connection".

%a escala de amplitude e tempo influencia muito na qualidade da aquisi��o
%do sinal, � importante que a amplitude do sinal esteja 100% na tela. a
%aquisi��o sera feita em valores reais, n�o importando a escala selecionada
%para a amplitude.

clc;    %Clear Command Window
%% Instrument Connection

% Create a VISA-USB object.
interfaceObj = instrfind('Type', 'visa-usb', 'RsrcName',    ...
    'USB0::0x0699  ::0x0368::C032206::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = visa('TEK', 'USB0::0x0699::0x0368::C032206::0::INSTR');
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Create a device object.
deviceObj = icdevice('tektronix_tds2000B.mdd', interfaceObj);

% Connect device object to hardware.
connect(deviceObj);

% inicia a opera��o das fun��es do grupo 'Waveform'
groupObj = get(deviceObj, 'Waveform');

%% inicio do c�digo de usu�rio
%� interessante que a leitura de dados sempre comece e termine em zero no
%   oscilosc�pio, isso diminui os erros do tempo de aquisi��o.
hA = 0; hB = 0;  %inicia o buffer da ultima posi��o
tic;    %inicia um cronometro
tempo = 1;    %tempo de observa��o e aquisi��o de sinais desejado (em segundos)
int = ceil(tempo/3.98); %o programa leva em media 4 segundos para fazer uma aquisi��o
% fileID = fopen('dados.txt','a');    %abre/cria o arquivo 'dados.txt' e autoliza a concateniza��o de dados
% fprintf(fileID,'\r\n --Inicio dos dados-- \r\n');   %grava informa��o '' no arquivo fileID
% fclose(fileID);     %fecha o arquivo fileID

%% loop de aquisi��o e armazenamento de dados
for i = 1:int       %Loop de aquisi��o - 2500 samples/aquisi��o
    BuffA = [hA];   %cria um vetor de buffer de dados
    BuffB = [hB];
    [A, t, U1] = invoke(groupObj, 'readwaveform', 'channel1');  %faz a leitura dos dados do oscilosc�pio no canal 1
    [B, x, U2] = invoke(groupObj, 'readwaveform', 'channel2');
    %         plot(t,A) %plota os dados obitidos na leitura do canal
    %         drawnow;  %for�a a execu��o do comendo plot
    BuffA = [BuffA, A];   %concatena os dados do buffer com os dados lidos
    BuffB = [BuffB, B];
    
    z = length(BuffA);   %mede o tamanho atual do buffer
    hA = BuffA(z-1);     %armazena o ultimo valor do buffer
    hB = BuffB(z-1);
    fileID = fopen('Tensaoteste4carga.txt','a');    %abre/cria o arquivo 'dados.txt' e autoliza a concateniza��o de dados
    fprintf(fileID,'%.2f\r\n', BuffA);   %grava os dados do buffer no arquivo fileID
    fclose(fileID);     %fecha o arquivo fileID
    fileID = fopen('Correnteteste4carga.txt','a');    %abre/cria o arquivo 'dados.txt' e autoliza a concateniza��o de dados
    fprintf(fileID,'%.2f\r\n', BuffB);   %grava os dados do buffer no arquivo fileID
    fclose(fileID);     %fecha o arquivo fileID
    
%     % Plot dos dados gerados na ultima aquisi��o
%     Ma = max(BuffA) + max(BuffA)/10;    %encontra o valor maximo do buffer
%     Mi = min(BuffA) - abs(min(BuffA)/10);     %encontra o valor minimo do buffer
%     figure('Name','Canal 1 - Oscilosc�pio', 'NumberTitle','off');
%     plot(BuffA)
%     xlim([0 z]);
%     ylim([Mi Ma]);
%     ylabel(U1);
%     drawnow;
%     ma = max(BuffB) + max(BuffB)/10;     %encontra o valor maximo do buffer
%     mi = min(BuffB) - abs(min(BuffB)/10);     %encontra o valor minimo do buffer
%     figure('Name','Canal 2 - Oscilosc�pio', 'NumberTitle','off');
%     plot(BuffB)
%     xlim([0 z]);
%     ylim([mi ma]);
%     ylabel(U2);
%     drawnow;
toc
end

%% marca��o de tempo e mensagem de finaliza��o de grava��o
t = toc  %marca o tempo decorrido no cronometro
% fileID = fopen('dados.txt','a');
% fprintf(fileID,'\r\n tempo decorrido: %.5f \r\n', t);
% fprintf(fileID,'\r\n --Final dos dados-- \r\n');
% fclose(fileID);
%% Fim do c�digo do usu�rio

%% Disconnect and Clean Up

% Disconnect device object from hardware.
disconnect(deviceObj);

% The following code has been automatically generated to ensure that any
% object manipulated in TMTOOL has been properly disposed when executed
% as part of a function or script.

% Clean up all objects.
delete([deviceObj interfaceObj]);
clear groupObj;
clear deviceObj;
clear interfaceObj;
% clear all;