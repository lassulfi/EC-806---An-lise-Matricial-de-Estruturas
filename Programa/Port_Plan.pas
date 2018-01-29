Program PortPlan;

uses Windows;

Const nmax = 50;

Type
    varstring = string;
    MatrizNxN = Array[1..nmax,1..nmax] of real;
    VetorN = Array[1..nmax] of real;
    Matriz6x6 = Array[1..6,1..6] of real;
    Vetor6x1r = Array[1..6] of real;
    Vetor6x1i = Array[1..6] of integer;
    //Criacao do record CarNos -> Armazena as caracteristicas dos nos da estrutura
    CarNos = record
             NNo: integer;//numero do no
             CoordX: real;//coordenada X do no
             CoordY: real;//coordenada Y do no
             End;
    //Criacao do record Elementos -> Armazena as caracteristicas dos elementos
    Elementos = record
                nelem : integer; //indice do elemento
                Noi : integer;//indice do no inicial
                Nof : integer;//indice do no final
                ME : real;//modulo de elasticidade do elemento
                A : real;//area da secao transversal
                I : real;//momento de inercia da secao no plano de flexao
                dx: real;//CoordXf-CoordXi
                dy: real;//CoordYf-CoordYi
                L: real;//comprimento do elemento
              End;
    //Criacao do record Carregamentos -> Armazena as caracteristicas dos carregamentos
    Carregamentos = record
                    tipo: integer;//tipo de carregamento atuante
                    No: integer;//numero de nos com carga concentrada
                    Fx: real;//valor da forca atuante na direcao x do no
                    Fy: real;//valor da forca atuante na direcao y do no
                    M: real;//valor do momento atuante no no
                    NEU: integer;//numero do elemento com carga uniformemente distribuida
                    q: real;//valor da carga uniformemente distribuida no elemento
                    NET: integer;//numero do elemento com carga trapezoidal (ou triangular)
                    qi: real;//valor da carga no inicio do elemento
                    qf: real;//valor da carga no final do elemento
                    End;
    //Criando o record Contorno -> Armazena as condicoes de contorno dos nos da estrutura
    Contorno = record
               No: integer;//numero do no com condicao de contorno
               dx: integer;//condicao de contorno na direcao x
               dy: integer;//condicao de contorno na direcao y
               dz: integer;//condicao de contorno na direcao z
               Rx: real;//Armazena o valor da reacao de apoio na direcao x
               Ry: real;//Armazena o valor da reacao de apoio na direcao y
               Rz: real;//Armazena o valor da reacao de apoio na direcao z
               delx: real;//Valor do recalque na direcao x
               dely: real;//Valor do recalque na direcao y
               delz: real;//Valor do recalque na direcao z
               End;
    //Criacao do record para armazenamento das forcas e esforcos dos elementos
    Acoes = record
            elem: integer;//armazena o número do elemento
            EP1: real;//Armazena o valor da incognita local 1
            EP2: real;//Armazena o valor da incognita local 2
            EP3: real;//Armazena o valor da incognita local 3
            EP4: real;//Armazena o valor da incognita local 4
            EP5: real;//Armazena o valor da incognita local 5
            EP6: real;//Armazena o valor da incognita local 6
            End;
    //Criacao do array de record de caracteristicas nodais
    DadosNos = Array[1..nmax] of CarNos;
    //Criacao do array de record de Elementos
    DadosElementos = Array[1..nmax] of Elementos;
    //Criacao do array de records de carregamentos
    DadosCarregamentos= Array[1..nmax] of Carregamentos;
    //Criacao do array de records de condicoes de contorno
    DadosContorno= Array[1..nmax] of Contorno;
    //Criacao do array de records de acoes
    ResultadoAcoes= Array[1..nmax] of Acoes;

Var
   nome_entrada: varstring; //nome do arquivo de dados de entrada lido na tela
   nome_saida: varstring;//nome do arquivo de dados de saida lido na tela
   nome_arquivo: text;//variavel que assume o nome do arquivo de dados
   nnos: integer;//numero de nos da estrutura
   nelem: integer;//numero de elementos da estrutura
   MatrizNos: DadosNos;//Matriz de caracteristicas dos nos
   MatrizElementos: DadosElementos;//Matriz das caracteristicas dos elementos da estrutura
   MatrizCarregamentos: DadosCarregamentos;//Matriz dos carregamentos atuantes na estrutura
   MatrizContorno: DadosContorno;//Matriz de condicoes de contorno da estrutura
   MatrizForcas: ResultadoAcoes;//Matriz das forcas nodais dos elementos da estrutura
   MatrizEsforcos: ResultadoAcoes;//Matriz dos esforcos dos elementos da estrutura
   ncar: integer;//numero de carregamentos atuante na estrutura
   nnoscar: integer;//numero de nos com carga concentrada
   nelemcud: integer;//numero de elementos com carga uniformemente distribuida
   nelemtrap: integer;//numero de elementos com carga trapezoidal (ou triangular)
   nnoscont: integer;//numero de nos com condicao de contorno
   SMD: MatrizNxN;//Matriz de rigidez da estrutura
   ANE: VetorN;//Vetor de acoes nodais equivalentes da estrutura
   D: VetorN;//Vetor dos deslocamentos nodais da estrutura no sistema de coordenadas global
   Vaux1: Vetor6x1r;//Vetor auxiliar 1 (real 6x1)
   i,j: integer;//contador
   aux1: integer;//variavel auxiliar inteira 1

//Funcao que calcula a potencia de um numero real qualquer a^b, sendo b um inteiro
Function Power(a: real;b: integer):real;

Var
   i: integer;//contador
   c: real;//constante que assume o valor da variavel a

Begin

c:=a;//c assume o valor de a

//multiplicacao de c*a b-1 vezes
For i:=1 to b-1 do
    c:=a*c;

Power:=c;

End;

//Procedimento para a leitura de dados a partir de um arquivo de texto
Procedure leitura_dados(Var nome : varstring; Var  narq : text; Var nnos,nelem, ncar, ncont, nnoscar, nelemcud, nelemtrap : integer;
                            Var Matriz1 : DadosElementos; Var Matriz2: DadosCarregamentos; Var Matriz3: DadosContorno;
                            Var Matriz4: DadosNos);

Var
   i : integer;

Begin

Write('Informe o arquivo de entrada de dados (Ex.: C:\Dados.txt => ');Readln(nome);
Assign(narq,nome);
Reset(narq);//Abre o arquivo de dados para leitura

//Leitura das caracteristicas dos nos da estrutura
Read(narq,nnos);//Leitura do numero de nos da estrutura
For i:=1 to nnos do
    Begin
    //Leitura das caracteristicas dos nos da estrutura
    Read(narq,Matriz4[i].NNo);
    Read(narq,Matriz4[Matriz4[i].NNo].CoordX);
    Read(narq,Matriz4[Matriz4[i].NNo].CoordY);
    End;

//Leitura das caracteristicas dos elementos da estrutura
Read(narq,nelem);//Leitura do numero de elementos da estrutura
For i:=1 to nelem do
    Begin
    //Leitura das caracteristicas do elemento
    Read(narq,Matriz1[i].nelem);//Leitura do indice do elemento
    Read(narq,Matriz1[Matriz1[i].nelem].Noi);//Leitura do indice do no incial do elemento
    Read(narq,Matriz1[Matriz1[i].nelem].Nof);//Leitura do indice do no final do elemento
    Read(narq,Matriz1[Matriz1[i].nelem].ME);//Leitura do mod. elasticidade do elemento
    Read(narq,Matriz1[Matriz1[i].nelem].A);//Leitura da area da secao transversal do elemento
    Read(narq,Matriz1[Matriz1[i].nelem].I);//Leitura do momento de inercia do elemento
    //Calculo de alguns paramentos do elemento
    Matriz1[Matriz1[i].nelem].dx:=
            Matriz4[Matriz1[Matriz1[i].nelem].Nof].CoordX-Matriz4[Matriz1[Matriz1[i].nelem].Noi].CoordX;//Calculo do dx do elemento
    Matriz1[Matriz1[i].nelem].dy:=
            Matriz4[Matriz1[Matriz1[i].nelem].Nof].CoordY-Matriz4[Matriz1[Matriz1[i].nelem].Noi].CoordY;//Calculo do dy do elemento
    Matriz1[Matriz1[i].nelem].L:=sqrt(Power(Matriz1[Matriz1[i].nelem].dx,2)+Power(Matriz1[Matriz1[i].nelem].dy,2));//Calculo do comprimento do elemento
    End;

//Leitura dos carregamentos atuantes na estrutura
Read(narq,ncar);//Leitura do numero de carregamentos atuante na estrutura
nnoscar:=0;
nelemcud:=0;
nelemtrap:=0;
For i:=1 to ncar do
    Begin
    Read(narq,Matriz2[i].tipo);//Leitura do tipo de carregamento atuante
    //Leitura das cargas concentradas atuantes na estrutura
    If Matriz2[i].tipo=1 then
       Begin
       nnoscar:=nnoscar+1;
       Read(narq,Matriz2[nnoscar].No);
       Read(narq,Matriz2[Matriz2[nnoscar].No].Fx);
       Read(narq,Matriz2[Matriz2[nnoscar].No].Fy);
       Read(narq,Matriz2[Matriz2[nnoscar].No].M);
       End
    Else
        If Matriz2[i].tipo=2 then
           Begin
           nelemcud:=nelemcud+1;
           Read(narq,Matriz2[nelemcud].NEU);
           Read(narq,Matriz2[Matriz2[nelemcud].NEU].q);
           End
        Else
            If Matriz2[i].tipo=3 then
               Begin
               nelemtrap:=nelemtrap+1;
               Read(narq,Matriz2[nelemtrap].NET);
               Read(narq,Matriz2[Matriz2[nelemtrap].NET].qi);
               Read(narq,Matriz2[Matriz2[nelemtrap].NET].qf);
               End;
    End;

//Leitura das condicoes de contorno de vinculacao dos nos da estrutura
Read(narq,ncont);//Leitura do numero de nso com condicao de contorno de vinculacao
For i:=1 to ncont do
    Begin
    Read(narq,Matriz3[i].No);//Leitura do numero do no com condicoes de contorno de vinculacao
    Read(narq,Matriz3[Matriz3[i].No].dx);//Leitura da condicao de contorno do no na direcao x
    If Matriz3[Matriz3[i].No].dx=2 then
       Read(narq,Matriz3[Matriz3[i].No].delx);//Leitura do valor do recalque na direcao x
    Read(narq,Matriz3[Matriz3[i].No].dy);//Leitura da condicao de contorno do no na direcao y
    If Matriz3[Matriz3[i].No].dy=2 then
       Read(narq,Matriz3[Matriz3[i].No].dely);//Leitura do valor do recalque na direcao y
    Read(narq,Matriz3[Matriz3[i].No].dz);//Leitura da condicao de contorno do no na direcao z
        If Matriz3[Matriz3[i].No].dz=2 then
       Read(narq,Matriz3[Matriz3[i].No].delz);//Leitura do valor do recalque na direcao z
    End;


Close(narq);

End;

//Montagem da matriz de rigidez do elemento no sistema de coordenadas globais
Procedure rigidez_local(Matriz: DadosElementos; indice: integer; Var KE: Matriz6x6);

Var
   E,A,I,L: real;//propriedades dos materiais e geometricas do elemento
   m,n: integer;//contador

Begin

//Definicao dos parametros utilizados para o calculo da matriz de rigidez do elemento
E:=Matriz[indice].ME;
A:=Matriz[indice].A;
I:=Matriz[indice].I;
L:=Matriz[indice].L;

//Tornando todos os coeficientes da matriz nulos
For m:=1 to 6 do
    For n:=1 to 6 do
        KE[m,n]:=0.0;

//Calculo dos coeficientes da matriz de rigidez do elemento de barra
KE[1,1]:=E*A/L;
KE[1,4]:=-KE[1,1];
KE[2,2]:=12*E*I/Power(L,3);
KE[2,3]:=6*E*I/Power(L,2);
KE[2,5]:=-KE[2,2];
KE[2,6]:=KE[2,3];
KE[3,2]:=KE[2,3];
KE[3,3]:=4*E*I/L;
KE[3,5]:=-KE[2,3];
KE[3,6]:=2*E*I/L;
KE[4,1]:=KE[1,4];
KE[4,4]:=KE[1,1];
KE[5,2]:=KE[2,5];
KE[5,3]:=-KE[2,3];
KE[5,5]:=KE[2,2];
KE[5,6]:=KE[5,3];
KE[6,2]:=KE[2,3];
KE[6,3]:=KE[3,6];
KE[6,5]:=KE[3,5];
KE[6,6]:=KE[3,3];

End;

//Procedimento que cria a matriz de transformacao de coordenadas para um elemento da estrutura
Procedure transformacao_coordenadas(Matriz: DadosElementos; indice: integer; Var T: Matriz6x6);

var dx, dy, L: real;
    cos, sen: real;//co-senos e senos dos angulos da barrra em relacao ao plano X-Y
    i,j: integer;//contadores

Begin

//Passando os valores do record Matriz para variaveis locais
dx:=Matriz[indice].dx;
dy:=Matriz[indice].dy;
L:=Matriz[indice].L;
cos:=dx/L;
sen:=dy/L;

//Tornando todos os valores da matriz T nulos
For i:=1 to 6 do
    For j:=1 to 6 do
        T[i,j]:=0.0;

//Criado a matriz de transformacao de coordenadas
T[1,1]:=cos;
T[1,2]:=sen;
T[2,1]:=-sen;
T[2,2]:=cos;
T[3,3]:=1.0;
T[4,4]:=cos;
T[4,5]:=sen;
T[5,4]:=-sen;
T[5,5]:=cos;
T[6,6]:=1.0;

End;

//criacao do vetor de cargas uniformemente distribuida perpendicular a barra no sistema de coordenadas local
procedure ANE_CUD_perp(Matriz1: DadosElementos; Matriz2: DadosCarregamentos; indice: integer; Var Vetor1: Vetor6x1r);

Var Le: real;//comprimento do elemento
    qe: real;//valor da carga no elemento
    i: integer;

Begin;

For i:=1 to 6 do
    Vetor1[i]:=0.0;

Le:=Matriz1[indice].L;
qe:=Matriz2[indice].q;
Vetor1[2]:=qe*Le/2;
Vetor1[3]:=qe*Power(Le,2)/12;
Vetor1[5]:=qe*Le/2;
Vetor1[6]:=-qe*Power(Le,2)/12;

End;

//cria o vetor de cargas linearmente distribuidas perpendicular a barra no sistema de coordenadas local
Procedure ANE_CLD_perp(Matriz1: DadosElementos; Matriz2: DadosCarregamentos; indice: integer; Var Vetor1: Vetor6x1r);

Var Le: real;//comprimento do elemento
    qei,qef: real;//valor da carga no no inicial e final do elemento
    i: integer;

Begin

For i:=1 to 6 do
    Vetor1[i]:=0.0;

Le:=Matriz1[indice].L;
qei:=Matriz2[indice].qi;
qef:=Matriz2[indice].qf;
Vetor1[2]:=7/20*qei*Le+3/20*qef*Le;
Vetor1[3]:=qef*Power(Le,2)/30+qei*Power(Le,2)/20;
Vetor1[5]:=3/20*qei*Le+7/20*qef*Le;
Vetor1[6]:=-1/30*qei*Power(Le,2)-1/20*qef*Power(Le,2);

End;

//Procedimento  calcula a matriz transposta
Procedure transposta(Matriz1: Matriz6x6; Var Matriz2: Matriz6x6);

Var i,j: integer;

Begin

For i:=1 to 6 do
    For j:=1 to 6 do
        Matriz2[i,j]:=Matriz1[j,i];

End;

//Procedimento para a multiplicacao de um vetor por uma matriz
Procedure multiplica_vetor(Matriz1: Matriz6x6; Vetor1: Vetor6x1r; Var Vetor2: Vetor6x1r);

Var i,j: integer;
    Soma: Real;

Begin

For i:=1 to 6 do
    Begin
    Soma:=0.0;
    For j:=1 to 6 do
        Soma:=Soma+Matriz1[i,j]*Vetor1[j];
    Vetor2[i]:=Soma;
    End;

End;

//procedimento para a multiplicacao de matrizes
Procedure multiplica_matriz(Matriz1, Matriz2: Matriz6x6; Var Matriz3: Matriz6x6);

Var i,j,k: integer;
    Soma: Real;

Begin

For i:=1 to 6 do
    For j:=1 to 6 do
        Begin
        Soma:=0.0;
        For k:=1 to 6 do
            Soma:=Soma+Matriz1[i,k]*Matriz2[k,j];
        Matriz3[i,j]:=Soma;
        End;

End;

//Procedimento para a realizacao do triplo produto
Procedure triplo_produto(Matriz1, Matriz2: Matriz6x6; Var Matriz3: Matriz6x6);

Var MatrizA, MatrizB: Matriz6x6;

Begin

//calculo da transposta da matriz de transformacao de coordenadas
transposta(Matriz1,MatrizA);

//calculo da primeira parcela do produto T^T*K
multiplica_matriz(MatrizA,Matriz2,MatrizB);

//calculo da segunda parcela do produto T^T*K*T
multiplica_matriz(MatrizB,Matriz1,Matriz3);

End;

//procedimento que faz a montagem da matriz de rigidez da estrutura
Procedure rigidez_estrutura(Matriz1 : DadosElementos; num,nnos: integer; Var Matriz2: MatrizNxN);

Var SM: Matriz6x6;//Matriz de rigidez do elemento no sistema de coordenadas local
    T: Matriz6x6;//Matriz de transformacao de coordenadas
    SMD: Matriz6x6;//Matriz de rigidez do elemento no sistema de coordenadas globais
    i,Nelem,IL,IC,Noi,Nof,ILG,ICG: integer;
    IG: Array[1..6] of integer;

Begin

//Tornando todos os valores da matriz de rigidez nulos
For ILG:= 1 to 3*nnos do
    For ICG:= 1 to 3*nnos do
        Matriz2[ILG,ICG]:=0.0;

//Tornando os valores de IG nulos
For i:=1 to 6 do
    IG[i]:=0;

For i:=1 to num do
    Begin
    Nelem:=Matriz1[i].nelem;
    //Criacao da matriz de rigidez do elemento no sistema de coordenadas local
    rigidez_local(Matriz1,Nelem,SM);
    //Criacao da matriz de transformacao de coordenadas
    transformacao_coordenadas(Matriz1,Nelem,T);
    //Criacao da matriz de rigidez do elemento no sistema de coordenadas global
    triplo_produto(T,SM,SMD);
    //Contribuicao da matriz de rigidez do elemento no sistema global para a matriz de rigidez da estrutura
    Noi:=Matriz1[Nelem].Noi;
    Nof:=Matriz1[Nelem].Nof;
    //Armazenamento dos indices globais no vetor IG
    IG[1]:=3*Noi-2;
    IG[2]:=3*Noi-1;
    IG[3]:=3*Noi;
    IG[4]:=3*Nof-2;
    IG[5]:=3*Nof-1;
    IG[6]:=3*Nof;
    //Contribuicao da matriz de rigidez do elemento considerado na matriz de rigidez global da estrutura
    For IL:=1 to 6 do
        Begin
        ILG:=IG[IL];
        For IC:=1 to 6 do
            Begin
            ICG:=IG[IC];
            Matriz2[ILG,ICG]:=Matriz2[ILG,ICG]+SMD[IL,IC];
            End;
        End;
    End;

End;

//Procedimento para a montagem do vetor de acoes nodais equivalentes na estrutura
Procedure ANE_global(Matriz1: DadosElementos; Matriz2: DadosCarregamentos; n1,n2,n3,n4: integer; Var Vetor1: VetorN);
//n1 -> numero de nos com carga concentrada
//n2 -> numero de elementos com carga uniformementes distribuida
//n3 -> numero de elementos com carga linearmente distruibuida
//n4 -> numero de nos da estrutura
//Vetor1 -> Vetor das das acoes nodais equivalentes

Var i,NNo,NElem,Noi,Nof,IC,ICG: integer;
    IG: Vetor6x1i;
    ANE: Vetor6x1r;
    T: Matriz6x6;
    Vaux1, Vaux2, Vaux3: VetorN;

Begin

//Tornando os dos valores de Vetor1 nulos
For i:=1 to 3*n4 do
    Begin
    Vetor1[i]:=0.0;
    Vaux1[i]:=0.0;
    Vaux2[i]:=0.0;
    Vaux3[i]:=0.0;
    End;

//Aplicacao das cargas concentradas nos nos dos elementos
   For i:=1 to n1 do
       Begin
       NNo:=Matriz2[i].No;//identificacao do numero do no com carga concentrada
       Vaux1[3*NNo-2]:=Vaux1[3*NNo-2]+Matriz2[NNo].Fx;//aplicacao da forca Fx no vetor ANE global
       Vaux1[3*NNo-1]:=Vaux1[3*NNo-1]+Matriz2[NNo].Fy;//Aplicacao da forca Fy no vetor ANE global
       Vaux1[3*NNo]:=Vaux1[3*NNo]+Matriz2[NNo].M;//Aplicacao do momento M no vetor ANE global
       End;

   //Aplicacao das cargas linearmente distribuidas
      For i:=1 to n2 do
          Begin
          //Determinacao do indice do elemento com carga uniformemente distriuida
          Nelem:=Matriz2[i].NEU;
          //Determinacao dos nos inicial e final do elemento
          Noi:=Matriz1[Nelem].Noi;
          Nof:=Matriz1[Nelem].Nof;
          //Tornando todos os valores do vetor ANE e IG nulos
          For IC:=1 to 6 do
              Begin
              ANE[IC]:=0.0;
              IG[IC]:=0;
              End;
          //Calculo do vetor de engastamento perfeito para o elemento
          ANE_CUD_perp(Matriz1,Matriz2,Nelem,ANE);
          //Calculo da matriz de transformacao de coordenadas do elemento
          transformacao_coordenadas(Matriz1,Nelem,T);
          //Calculo da transposta da matriz de transformacao de coordenadas
          transposta(T,T);
          //Calculo do ANE no sistema de coordenadas global
          multiplica_vetor(T,ANE,ANE);
          //Determinacao dos indices globais do ANE
          IG[1]:=3*Noi-2;
          IG[2]:=3*Noi-1;
          IG[3]:=3*Noi;
          IG[4]:=3*Nof-2;
          IG[5]:=3*Nof-1;
          IG[6]:=3*Nof;
          //Alocacao dos valores dos ANE no vetor auxiliar 2
          For IC:=1 to 6 do
              Begin
              ICG:=IG[IC];
              Vaux2[ICG]:=Vaux2[ICG]-ANE[IC];
              End;
          End;

       //Aplicacao das cargas linearmente distribuidas perpendicular as barras no vetor de acoes nodais equivalentes
       For i:=1 to n3 do
           Begin
           NElem:= Matriz2[i].NET;//Identificacao do elemento com carga triangular
           Noi:= Matriz1[NElem].Noi;//Identificacao do no inicial do elemento
           Nof:= Matriz1[NElem].Nof;//Identificacao do no final do elemento
           For IC:=1 to 6 do
               Begin
               IG[IC]:=0;
               ANE[IC]:=0.0;
               End;
           //Criacao do vetor ANE para carga trapezoidal no sistema de coordenadas local
           ANE_CLD_perp(Matriz1,Matriz2,Nelem,ANE);
           //Criacao da matriz de transformacao de coordenadas do elemento
           transformacao_coordenadas(Matriz1,Nelem,T);
           //Determinacao da matriz de transformacao de coordenadas transposta
           transposta(T,T);
           //Criacao do vetor ANE para carga trapezoidal no sistema de coordenadas global
           multiplica_vetor(T,ANE,ANE);
           //Armazenamento dos indices globais no vetor IG
           IG[1]:=3*Noi-2;
           IG[2]:=3*Noi-1;
           IG[3]:=3*Noi;
           IG[4]:=3*Nof-2;
           IG[5]:=3*Nof-1;
           IG[6]:=3*Nof;
           For IC:=1 to 6 do
               Begin
               ICG:=IG[IC];
               Vaux3[ICG]:=Vaux3[ICG]-ANE[IC];
               End;
           End;

//Contribuicao de todos os carregamentos para o vetor de acoes nodais equivalentes
For i:=1 to 3*n4 do
    Vetor1[i]:=Vaux1[i]+Vaux2[i]+Vaux3[i];

End;

//procedimento para a imposicao das condicoes de contorno de vinculacao na matriz de rigidez da estrutura
//e no vetor de acoes nodais equivalentes
Procedure Condicao_Contorno(n1,n2: integer; Matriz1: DadosContorno; Var Matriz2: MatrizNxN; Var Vetor1: VetorN);
//n1 -> numero de nos com condicao de contorno
//n2 -> numero de nos da estrutura
//Matriz2 -> Matriz de rigidez da estrutura
//Vetor1 -> Vetor de Acoes nodais equivalentes

Var

i,j,Noc: integer;

Begin

//Aplicacao das restricoes nos apoios
For i:=1 to n1 do
    Begin
    Noc:= Matriz1[i].No;
    //Aplicacao na direcao x
    If Matriz1[Noc].dx = 1 then
       Begin
       For j:=1 to 3*n2 do
           Begin
           Matriz2[3*Noc-2,j]:= 0.0;
           Matriz2[j,3*Noc-2]:=0.0;
           End;
       Matriz2[3*Noc-2,3*Noc-2]:=1.0;
       Vetor1[3*Noc-2]:=0.0;
       End
    else
       //recalque na direcao x
       If Matriz1[Noc].dx = 2 then
       Begin
       For j:=1 to 3*n2 do
           Begin
           Vetor1[j]:=Vetor1[j]-Matriz2[j,3*Noc-2]*Matriz1[Noc].delx;
           Matriz2[3*Noc-2,j]:= 0.0;
           Matriz2[j,3*Noc-2]:=0.0;
           End;
       Matriz2[3*Noc-2,3*Noc-2]:=1.0;
       Vetor1[3*Noc-2]:=Matriz1[Noc].delx;
       End;
    //Aplicacao na direcao y
    If Matriz1[Noc].dy = 1 then
       Begin
       For j:=1 to 3*n2 do
           Begin
           Matriz2[3*Noc-1,j]:=0.0;
           Matriz2[j,3*Noc-1]:=0.0;
           End;
       Matriz2[3*Noc-1,3*Noc-1]:=1.0;
       Vetor1[3*Noc-1]:=0.0;
       End
    else
       //recalque na direcao y
       If Matriz1[Noc].dy = 2 then
       Begin
       For j:=1 to 3*n2 do
           Begin
           Vetor1[j]:=Vetor1[j]-Matriz2[j,3*Noc-1]*Matriz1[Noc].dely;
           Matriz2[3*Noc-1,j]:=0.0;
           Matriz2[j,3*Noc-1]:=0.0;
           End;
       Matriz2[3*Noc-1,3*Noc-1]:=1.0;
       Vetor1[3*Noc-1]:=Matriz1[Noc].dely;
       End;
    //Aplicacao na direcao z
    If Matriz1[Noc].dz = 1 then
       Begin
       For j:=1 to 3*n2 do
           Begin
           Matriz2[3*Noc,j]:=0.0;
           Matriz2[j,3*Noc]:=0.0;
           End;
       Matriz2[3*Noc,3*Noc]:=1.0;
       Vetor1[3*Noc]:=0.0;
       End
    else
       //Aplicacao do recalque na direcao de z
       If Matriz1[Noc].dz = 2 then
       Begin
       For j:=1 to 3*n2 do
           Begin
           Vetor1[j]:=Vetor1[j]-Matriz2[j,3*Noc]*Matriz1[Noc].delz;
           Matriz2[3*Noc,j]:=0.0;
           Matriz2[j,3*Noc]:=0.0;
           End;
       Matriz2[3*Noc,3*Noc]:=1.0;
       Vetor1[3*Noc]:=Matriz1[Noc].delz;
       End;
    End;

End;

//Rotina de Cholesky para a resolucao do sistema linear S*D=A
//Rotina obtida do material de apoio da disciplina EC834 - Tecnicas de Progamacao
//Prof. Dr. Francisco Antonio Menezes
procedure Cholesky(N:integer; A: MatrizNxN; B:VetorN; Var X: VetorN);
var
 i,j,k: integer;
 soma: real;
 Y: vetorN;
 begin
{ DECOMPOSICAO }
{ OBS - os elementos das matrizes L e L' serao armazenados na propria matriz A}

{montagem da matriz L}
for i:=1 to n do
 begin
  {elementos abaixo da diagonal principal}
  for j:=1 to i-1 do
   begin
    soma:=0.0;
    for k:=1 to j-1 do
     soma:=soma+a[j,k]*a[i,k];
    a[i,j]:=(a[i,j]-soma)/a[j,j];
   end;
  {elementos da diagonal principal}
  soma:=0.0;
  for k:=1 to i-1 do
   soma:=soma+sqr(a[i,k]);
  if (a[i,i]-soma)<0.0
   then
    begin
    MessageBox (0, 'Não foi possível resolver a estrutura! Verifique os dados!' , 'Erro', 0 + MB_ICONEXCLAMATION);
     halt;
    end;
  a[i,i]:=Sqrt(a[i,i]-soma);
 end;

{montagem da MATRIZ L' - por simetria}
for i:=1 to n do
 for j:=i+1 to n do
  a[i,j]:=a[j,i];

{SOLUCAO DO SISTEMA LL'X=B}
{a. PARTE I -  LY=B}
{solucao com susbstituicao para frente}
y[1]:=b[1]/a[1,1];
for i:=2 to n do
 begin
  for j:=1 to i-1 do
   b[i]:=b[i]-a[i,j]*y[j];
  y[i]:=b[i]/a[i,i];
 end;

{b. PARTE II - L'X=Y}
{retrosubstituicao}
x[n]:=y[n]/a[n,n];
for i:=n-1 downto 1 do
 begin
  for j:=n downto i+1 do
   y[i]:=y[i]-a[i,j]*x[j];
  x[i]:=y[i]/a[i,i];
 end;
end;{final da subrotina Cholesky}

//Procedimento para o calculo das forcas nodais nos elementos
Procedure acoes_elemento(n1: integer; Vetor1 : VetorN; Matriz1: DadosElementos; Var Vetor2: Vetor6x1r);
//n1 -> Indice do elemento

Var Noi, Nof: integer;//Nos inicial e final do elemento
    T: Matriz6x6;//Matriz de transformacao de coordenadas
    D: Vetor6x1r;//Vetor deslocamentos do elemento
    SM: Matriz6x6;//Matriz de rigidez do elemento no sistema de coordenadas local

Begin

//Determinacao dos nos inicial e final do elemento
Noi:=Matriz1[n1].Noi;
Nof:=Matriz1[n1].Nof;

//Determinacao do vetor deslocamentos do elemento no sistema de coordenadas local
D[1]:=Vetor1[3*Noi-2];
D[2]:=Vetor1[3*Noi-1];
D[3]:=Vetor1[3*Noi];
D[4]:=Vetor1[3*Nof-2];
D[5]:=Vetor1[3*Nof-1];
D[6]:=Vetor1[3*Nof];

//Determinacao da matriz de transformacao de coordenadas
transformacao_coordenadas(Matriz1,n1,T);

//Determinacao da matriz de rigidez do elemento no sistema de coordenadas local
rigidez_local(Matriz1,n1,SM);

//Determinacao do vetor deslocamentos no sistema de coordenadas global
multiplica_vetor(T,D,D);

//Determinacao das forcas nos nos (produto SM*D)
multiplica_vetor(SM,D,Vetor2);

End;

//Procedimento para o calculo dos esforcos nodais do elemento
Procedure esforcos_elemento(n1,n2,n3: integer; Vetor2: VetorN; Matriz1: DadosElementos; Matriz2: DadosCarregamentos;
                                   Var Matriz3: ResultadoAcoes);
//n1 -> numero do elemento
//n2 -> numero de cargas uniformemente distribuidas
//n3 -> numero de cargas linearmente distribuidas
//Vetor1 -> vetor das acoes nodais equivalentes
//Vetor2 -> Vetor dos deslocamentos nodais

Var aux1: integer;//Variavel auxiliar 1 inteira
    aux2: integer;//Variavel auxiliar 2 inteira
    Vaux1: Vetor6x1r;//Vetor auxilar 1 (6x1 real)
    EP: Vetor6x1r;//Criacao do vetor de engastamentos perfeitos para o elemento
    AN: Vetor6x1r;//Vetor de acoes nodais do elemento
    i,j: integer;//contador

Begin

aux1:= Matriz1[n1].nelem;//Determinacao do elemento estudado

//Tornando todos os valored od vetor EP nulos
For i:=1 to 6 do
    Begin
    EP[i]:=0.0;
    Vaux1[i]:=0.0;
    End;

//Determinacao do vetor de engastamentos perfeitos do elementos
//Determinacao do engastamento perfeito para o caso de carga uniformemente distribiuida
If n2 <>0 then
   Begin
   For i:=1 to n2 do
       Begin
       aux2:= Matriz2[i].NEU;
       If aux2 = aux1 then
          Begin
          ANE_CUD_perp(Matriz1,Matriz2,aux1,Vaux1);
          //Contribuicao de todos os carregamentos uniformemente distribuidos atuantes nesse elemento
          For j:=1 to 6 do
              EP[j]:=EP[j]+Vaux1[j];
              End;
       End;
   End
   else
   If n3 <> 0 then
      Begin
      //Determinacao do engastamento perfeito para o caso de carga linearmente distribuida
      For i:=1 to n3 do
          Begin
          aux2:= Matriz2[i].NET;
          If aux2 = aux1 then
             Begin
             ANE_CLD_perp(Matriz1,Matriz2,aux1,Vaux1);
             //Contribuicao de todos os carregamentos linearmente distribuidos atuantes nesse elemento
             For j:=1 to 6 do
             EP[j]:=EP[j]+Vaux1[j];
             End;
          End;
      End;

//Determinacao do vetor de acoes nodais equivalentes
acoes_elemento(aux1,Vetor2,Matriz1,AN);

//Calculo do vetor de esforcos nodais do elemento
Matriz3[aux1].EP1:=EP[1]+AN[1];
Matriz3[aux1].EP2:=EP[2]+AN[2];
Matriz3[aux1].EP3:=EP[3]+AN[3];
Matriz3[aux1].EP4:=EP[4]+AN[4];
Matriz3[aux1].EP5:=EP[5]+AN[5];
Matriz3[aux1].EP6:=EP[6]+AN[6];

End;

//Procedimento para o calculo das reacoes de apoio da estrutura
Procedure reacoes_apoio(n1,n2,n3: integer; Matriz2: DadosElementos; Matriz3: ResultadoAcoes;
                                     Matriz4: DadosCarregamentos; Var  Matriz1: DadosContorno);
//n1 -> numero de nos com condicao de contorno
//n2 -> numero de elementos da estrutura
//n3 -> numero de nos com carga concentrada
//Vetor1 -> Vetor dos deslocamentos da estrutura

Var No: integer;//numero do no com condicao de contorno
    nelem: integer;//numero do elemento
    Noi, Nof: integer;//Nos inicial e final do elemento
    NCC: integer;//No com carga concentrada
    i,j: integer;//contador
    aux1,aux2,aux3,aux4,aux5,aux6: real;//Variavel auxiliar 1 real
    T: Matriz6x6;//Matriz de transformacao de coordenadas
    EN: Vetor6x1r;//Vetor de esforcos nodais do elemento

Begin

For i:= 1 to 3*n1 do
    Begin
    Matriz1[i].Rx:=0.0;
    Matriz1[i].Ry:=0.0;
    Matriz1[i].Rz:=0.0;
    End;

//Determinacao do numero do no com condicao de contorno
For i:=1 to n1 do
    Begin
    No:=Matriz1[i].No;
    //Contribuicao das cargas concentradas nos nos
    For j:= 1 to n3 do
        Begin
        NCC:=Matriz4[i].No;
        If NCC = No then
           Begin
           Matriz1[No].Rx:=Matriz1[No].Rx-Matriz4[i].Fx;
           Matriz1[No].Ry:=Matriz1[No].Ry-Matriz4[i].Fy;
           Matriz1[No].Rz:=Matriz1[No].Rz-Matriz4[i].M;
           End;
        End;
    aux1:=0.0;
    aux2:=0.0;
    aux3:=0.0;
    aux3:=0.0;
    aux4:=0.0;
    aux5:=0.0;
    aux6:=0.0;
    For j:=1 to n2 do
        Begin
        nelem:= Matriz2[j].Nelem;
        //Determinacao da matriz de transformacao de coordenadas do elemento
        transformacao_coordenadas(Matriz2,nelem,T);
        EN[1]:=Matriz3[nelem].EP1;
        EN[2]:=Matriz3[nelem].EP2;
        EN[3]:=Matriz3[nelem].EP3;
        EN[4]:=Matriz3[nelem].EP4;
        EN[5]:=Matriz3[nelem].EP5;
        EN[6]:=Matriz3[nelem].EP6;
        //Calculo da transposta de T
        transposta(T,T);
        //Determinacao do vetor de esforcos nodais no sistema de coordenadas local
        multiplica_vetor(T,EN,EN);
        //Verificacao para o no inicial do elemento
        Noi:= Matriz2[nelem].Noi;
        If Noi = No then
           Begin
           //Contribuicao na direcao dx
           If (Matriz1[No].dx = 1) or (Matriz1[No].dx = 2) then
              aux1:=aux1+EN[1];
           //Contribuicao na direcao dy
           If (Matriz1[No].dy = 1) or (Matriz1[No].dy = 2) then
              aux2:=aux2+EN[2];
           //Contribuicao na direcao dz
           If (Matriz1[No].dz = 1) or (Matriz1[No].dz = 2) then
              aux3:=aux3+EN[3];
           End;
        //Verificacao para o no final do elemento
        Nof:= Matriz2[nelem].Nof;
        If Nof = No then
           Begin
           //Contribuicao na direcao x
           If (Matriz1[No].dx = 1) or (Matriz1[No].dx = 2) then
              aux4:=aux4+EN[4];
           //Contribuicao na direcao dy
           If (Matriz1[No].dy = 1) or (Matriz1[No].dy = 2) then
              aux5:=aux5+EN[5];
           //Contribuicao na direcao dz
           If (Matriz1[No].dz = 1) or (Matriz1[No].dz = 2) then
              aux6:=aux6+EN[6];
           End;
        Matriz1[No].Rx:=aux1+aux4;
        Matriz1[No].Ry:=aux2+aux5;
        Matriz1[No].Rz:=aux3+aux6;
        End;
    End;

End;

//Procedimento de impressao de resultados em um arquivo de dados
Procedure impressao_resultados(Var nome : varstring; Var narq: text; nome3: varstring; n1,n2,n3,n5,n6,n7: integer;
                                     Matriz1: DadosNos; Matriz2: DadosElementos; Matriz3: DadosContorno;
                                     Matriz4: DadosCarregamentos; Matriz5: ResultadoAcoes; Matriz7: ResultadoAcoes;
                                     Vetor1: VetorN);
//n1 -> numero de nos da estrutura
//n2 -> numero de elementos da estrutura
//n3 -> numero de nos com condicao de contorno de vinculacao
//n5 -> numero de nos com carga concentrada aplicada
//n6 -> numero de elementos com carga uniformemente distribuida
//n7 -> numero de elementos com carga linearmente distribuidas
//Vetor1 -> Vetor dos deslocamentos nodais no sistema global da estrutura
//Matriz5 -> Matriz dos esforcos nodais equivalentes


Var
   i: integer;//contador
   aux1: integer;//variaveis auxiliares

Begin

Writeln;
Write('Informe o arquivo de saida de dados (Ex.: C:\Resultados.txt => ');Readln(nome);
Assign(narq,nome);
Rewrite(narq);

Writeln(narq);
Writeln(narq,'?????????????????????????????????????????????????????????????????????????');
Writeln(narq,'?                                                                       ?');
Writeln(narq,'?                                                                       ?');
Writeln(narq,'?            PortPlan - Programa para Analise de Porticos               ?');
Writeln(narq,'?                                 Planos                                ?');
Writeln(narq,'?                                                                       ?');
Writeln(narq,'?                                                                       ?');
Writeln(narq,'?           Metodo Numerico - Analise Matricial de Estruturas           ?');
Writeln(narq,'?                                                                       ?');
Writeln(narq,'?                                                                       ?');
Writeln(narq,'?????????????????????????????????????????????????????????????????????????');
Writeln(narq);

Writeln(narq);
//Impressao do nome do arquivo lido

Write(narq,' Problema analisado => ');Writeln(narq,nome3);

Writeln(narq);
Writeln(narq,' Dados dos Nos ');
Writeln(narq);

Writeln(narq);
//Impressao das coordenadas nodais da estrutura
Writeln(narq,' Coordenadas Nodais ');
Writeln(narq);
Writeln(narq,' No ',' Coordenada X ',' Coordenada Y ');
For i:= 1 to n1 do
    Begin
    aux1:=Matriz1[i].NNo;
    Writeln(narq,'   ',aux1,'  ',Matriz1[aux1].CoordX:10:4,Matriz1[aux1].CoordY:10:4);
    End;

Writeln(narq);
//Impressao dos nos com condicao de contorno
Writeln(narq,' Nos com vinculaoes fixas ');
Writeln(narq);
Writeln(narq,' No ','  Desloc. X  ','  Desloc Y ','  Desloc Z ');
For i:=1 to n3 do
    Begin
    aux1:=Matriz3[i].No;
    Write(narq,'  ',aux1,' ');
    If (Matriz3[aux1].dx=1) or (Matriz3[aux1].dx=2) then
       Write(narq,'   Impedido ')
    else
        Write(narq,'     Livre  ');
    If (Matriz3[aux1].dy=1) or (Matriz3[aux1].dy=2) then
       Write(narq,'   Impedido ')
    else
        Write(narq,'     Livre  ');
    If (Matriz3[aux1].dz=1) or (Matriz3[aux1].dz=2) then
       Write(narq,'   Impedido')
    else
        Write(narq,'     Livre');
    Writeln(narq);
    End;

Writeln(narq);
//Impressao dos nos com recalque de apoio
   Writeln(narq,' Nos com recalque de apoio ');
   Writeln(narq);
   Writeln(narq,' No ',' Recalque X ',' Recalque Y ',' Recalque Z ');
For i:=1 to n3 do
    Begin
    aux1:=Matriz3[i].No;
    Write(narq,'  ',aux1,' ');
    If Matriz3[aux1].dx=2 then
       Write(narq,'   ',Matriz3[aux1].delx:6:4)
    else
       Write(narq,'   ',0.0:6:4);
    If Matriz3[aux1].dy=2 then
       Write(narq,'       ',Matriz3[aux1].dely:6:4)
    else
       Write(narq,'       ',0.0:6:4);
    If Matriz3[aux1].dz=2 then
       Write(narq,'       ',Matriz3[aux1].delz:6:4)
    else
       Write(narq,'       ',0.0:6:4);
    Writeln(narq);
    End;

Writeln(narq);
Writeln(narq,' Dados dos Elementos ');
Writeln(narq);

Writeln(narq);
//Impressao das caracteristicas dos elementos
Writeln(narq,' Caracteristicas dos Elementos ');
Writeln(narq);
Writeln(narq,' Elem. ',' No i ',' No f ','  Mod. Elas. ','  Inercia ','    Area   ','  Comprimento ');
For i:=1 to n2 do
    Begin
    aux1:=Matriz2[i].nelem;
    Writeln(narq,'   ',aux1,'     ',Matriz2[aux1].Noi,'      ',Matriz2[aux1].Nof,' ',Matriz2[aux1].ME:10:4,'   ',Matriz2[aux1].I:9:4,'   ',
                    Matriz2[aux1].A:9:4,'    ',Matriz2[aux1].L:7:4);
    End;

If (n5<>0) or (n6<>0) or (n7<>0) then
   Begin
   Writeln(narq);
   Writeln(narq,' Dados dos Carregamentos ');
   Writeln(narq);
   //Impressao dos nos com carga concentrada
   If n5<>0 then
      Begin
      Writeln(narq,' Nos com carga concentrada ');
      Writeln(narq);
      Writeln(narq,' No ','    Fx   ','      Fy   ','     M ');
      For i:=1 to n5 do
          Begin
          aux1:= Matriz4[i].No;
          Writeln(narq,' ',aux1,' ',Matriz4[aux1].Fx:9:4,' ',Matriz4[aux1].Fy:9:4,' ',Matriz4[aux1].M:9:4);
          End;
      End;
   Writeln(narq);
   //Impressao dos elementos com carga uniformemente distribuidas
   If n6 <> 0 then
      Begin
      Writeln(narq,' Elementos com carga uniformemente distribuidas ');
      Writeln(narq);
      Writeln(narq,' Elem. ','     q ');
      For i:=1 to n6 do
          Begin
          aux1:=Matriz4[i].NEU;
          Writeln(narq,'   ',aux1,' ',Matriz4[aux1].q:9:4);
          End;
      End;
      Writeln(narq);
      //Impressao dos elementos com carga linearmente distribuidas
      If n7 <> 0 then
         Begin
         Writeln(narq,' Elementos om carga linearmente distribuidas ');
         Writeln(narq,' Elem. ','   qi   ','   qf ');
         For i:=1 to n7 do
             Begin
             aux1:=Matriz4[i].NET;
             Writeln(narq,'   ',aux1,' ',Matriz4[aux1].qi:9:4,' ',Matriz4[aux1].qf:9:4);
             End;
         End;
   End;

Writeln(narq);
Writeln(narq,' Impressao dos Resultados da Analise Estatica ');
Writeln(narq);

//Impressao dos deslocamentos nodais
Writeln(narq,' Deslocamentos Nodais (Sistema Global) ');
Writeln(narq,' No ',' Desloc. X ',' Desloc Y ',' Giro Z ');
For i:=1 to n1 do
    Begin
    aux1:=Matriz1[i].NNo;
    Writeln(narq,' ',aux1,' ',Vetor1[3*aux1-2]:10,' ',Vetor1[3*aux1-1]:10,' ',Vetor1[3*aux1]:10);
    End;

//Impressao das acoes nodais equivalentes no elemento
Writeln(narq);
Writeln(narq,' Forcas Nodais no Elemento ');
Writeln(narq,' Elem. ',' No i. ','   1   ','     2   ','   3 ');
Writeln(narq,'       ',' No f. ','   4   ','     5   ','   6 ');
For i:=1 to n2 do
    Begin
    aux1:=Matriz2[i].nelem;
    Writeln(narq,'    ',aux1,'    ',Matriz2[aux1].Noi,' ',Matriz7[aux1].EP1:9:4,' ',Matriz7[aux1].EP2:9:4,' ',Matriz7[aux1].EP3:9:4);
    Writeln(narq,'         ',Matriz2[aux1].Nof,' ',Matriz7[aux1].EP4:9:4,' ',Matriz7[aux1].EP5:9:4,' ',Matriz7[aux1].EP6:9:4);
    End;

//Impressao dos esforcos nodais no elemento
Writeln(narq);
Writeln(narq,' Esforcos Nodais no Elemento ');
Writeln(narq,' Elem. ',' No i. ','   N   ','     V   ','   M ');
Writeln(narq,'       ',' No f. ');
For i:=1 to n2 do
    Begin
    aux1:=Matriz2[i].nelem;
    Writeln(narq,'    ',aux1,'    ',Matriz2[aux1].Noi,' ',Matriz5[aux1].EP1:9:4,' ',Matriz5[aux1].EP2:9:4,' ',Matriz5[aux1].EP3:9:4);
    Writeln(narq,'         ',Matriz2[aux1].Nof,' ',Matriz5[aux1].EP4:9:4,' ',Matriz5[aux1].EP5:9:4,' ',Matriz5[aux1].EP6:9:4);
    End;

//Impressao das reacoes de apoio dos nos com condicao de contorno de vinculacao
Writeln(narq);
Writeln(narq,' Reacoes de Apoio ');
Writeln(narq,' No ','    Rx   ','     Ry   ','     Rz ');
For i:=1 to n3 do
    Begin
    aux1:=Matriz3[i].No;
    Writeln(narq,' ',aux1,' ',Matriz3[aux1].Rx:9:4,' ',Matriz3[aux1].Ry:9:4,' ',Matriz3[aux1].Rz:9:4);
    End;

Close(narq);

End;

//Inicio do programa
Begin

//Leitura dos dados do problema a ser analisado
leitura_dados(nome_entrada,nome_arquivo,nnos,nelem,ncar,nnoscont,nnoscar,nelemcud,nelemtrap,
               MatrizElementos,MatrizCarregamentos,MatrizContorno,MatrizNos);

//Tornando os valores da matriz de rigidez da estrutura nulos
For i:=1 to 3*nnos do
    For j:=1 to nnos do
        SMD[i,j]:=0.0;

//Montagem da matriz de rigidez da estrutura
rigidez_estrutura(MatrizElementos,nelem,nnos,SMD);

//Criacao do vetor de acoes nodais equivalentes da estrutura
ANE_global(MatrizElementos,MatrizCarregamentos,nnoscar,nelemcud,nelemtrap,nnos,ANE);

//Aplicacao das condicoes de contorno de vinculacao na matriz de rigidez da estrutura
Condicao_Contorno(nnoscont,nnos,MatrizContorno,SMD,ANE);

//Determinacao do vetor de deslocamentos nodais da estrutura - Solucao do sistema linear SMD*D=ANE por CHOLESKY
Cholesky(3*nnos,SMD,ANE,D);

//Calculo das forcas nodais nos elementos da estrutura
For i:=1 to nelem do
    Begin
    aux1:=MatrizElementos[i].NElem;
    acoes_elemento(i,D,MatrizElementos,Vaux1);
    MatrizForcas[aux1].elem:=aux1;
    MatrizForcas[aux1].EP1:=Vaux1[1];
    MatrizForcas[aux1].EP2:=Vaux1[2];
    MatrizForcas[aux1].EP3:=Vaux1[3];
    MatrizForcas[aux1].EP4:=Vaux1[4];
    MatrizForcas[aux1].EP5:=Vaux1[5];
    MatrizForcas[aux1].EP6:=Vaux1[6];
    End;


//Calculo dos esforcos nodais dos elementos da estrutura
For i:=1 to nelem do
    Begin
    esforcos_elemento(i,nelemcud,nelemtrap,D,MatrizElementos,MatrizCarregamentos,MatrizEsforcos);
    End;

//Calculo das reacoes de apoio dos nos com condicao de contorno de vinculacao
reacoes_apoio(nnoscont,nelem,ncar,MatrizElementos,MatrizEsforcos,MatrizCarregamentos,MatrizContorno);

//Impressao dos resultados em um arquivo de dados
impressao_resultados(nome_saida,nome_arquivo,nome_entrada,nnos,nelem,nnoscont,nnoscar,nelemcud,nelemtrap,
                                     MatrizNos,MatrizElementos,MatrizContorno,MatrizCarregamentos,MatrizEsforcos,MatrizForcas,D);

MessageBox (0, 'Programa executado com sucesso! Verifique o arquivo de resultados!' , 'Mensagem', 0 + MB_ICONASTERISK);

End.
