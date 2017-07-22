//---------------------------------------------------------------------------------------------------------------------------
//	Adarlan Alves's Snake
//	Este código fonte é compatível com o compilador Pascal ZIM! Versão 5.0
Program Cobra;

	//----------------------------------------------------------------------------------------------------------------------
	//	Lista de constantes: Esta lista foi criada para facilitar algumas modificações básicas do programa
	Const
		Largura=36;	// Largura da grade (área interna, sem contar as paredes)
		Altura=21;	// Altura da grade (área interna, sem contar as paredes)
		//	Neste programa há uma grade representada na tela, sendo que o sistema de
		//	coordenadas utilizado em todo o programa é cartesiano (NÃO segue a lógica de matrizes).
		//
		//	Exemplo de grade:
		//		  0  1  2  3  4  5  6  x
		//		0[#][#][#][#][#][#][#]
		//		1[#][ ][ ][ ][ ][ ][#]		[#]-> Parede
		//		2[#][ ][ ][ ][ ][ ][#]		[ ]-> Célula vazia
		//		3[#][ ][ ][ ][ ][ ][#]
		//		4[#][ ][ ][ ][ ][ ][#]
		//		5[#][ ][ ][ ][ ][ ][#]		Neste exemplo Largura=5 e Altura=5 (sem contar as paredes)
		//		6[#][#][#][#][#][#][#]
		//		y
		//
		QtdObstaculos=100;	// Quantidade de obstáculos na grade
		pps=20;	// Passos por segundo (Número aproximado de vezes que a repetição principal será executada por segundo)
		TamanhoMaximo=100;	// Tamanho máximo que a cobra poderá atingir
		CorParede=red;	// Cor da parede e dos obstáculos
		CorCobra=black;	// Cor da cobra
		CorPonto=lightblue;	// Cor do pontinho que aparece aleatoriamente na grade
		CorFundo=green;	// Cor do plano de fundo da grade

	//----------------------------------------------------------------------------------------------------------------------
	Var
		Tamanho,	// Quantidade de células ocupadas pela cobra
		SentidoHorizontal,	// Para a esquerda ou para a direita...
		SentidoVertical,	// Para cima ou para baixo
		tempo,	// O inverso de velocidade
		TempoRestante,	// Contador regressivo (tempo que falta para o próximo movimento)
		PontoX, PontoY,	// Coordenadas do ponto que aparece aleatoriamente na grade
		i, j, k: integer;	// Contadores, armazenadores temporários
		X, Y:	array[1..TamanhoMaximo] of integer;	// Coordenadas das células ocupadas pelo corpo da cobra
		ObstaculoX, ObstaculoY: array[1..QtdObstaculos] of integer;	// Coordenadas dos obstáculos
		tecla: char;	// Para ler os comandos do usuário
		PegouPonto: boolean;	// Flag que indica se a cobra pegou um ponto

	//------------------------------------------------------------------------------------------------------------------------------
	//	Procedure DesenharCelula: Desenha na grade a célula (x,y) com o caractere dado.
	//	Para desenhar a célula (x,y) na tela de vídeo do pascal é preciso
	//	posicionar o cursor na coluna 2*x+3, linha y+2 com a função gotoxy(2*x+3, y+2).
	//	Isso por que cada célula da grade ocupa 2 colunas por 1 linha (multiplicadores).
	//	E a primeira célula é desenhada na 3ª coluna, 2ª linha (valores iniciais).
	Procedure DesenharCelula(x_, y_: integer; caractere: char);
		Begin
			gotoxy(2*x_+3,y_+2);	// Posicionar o cursor na coluna 2*x+3, linha y+2
			write(caractere,caractere);	// O caractere é impresso duas vezes (cada célula ocupa 1 linha por 2 colunas)
		End;

	//------------------------------------------------------------------------------------------------------------------------------
	//	Function CelulaVazia: Retorna TRUE se a a célula (x, y) não está sendo ocupada pela cobra ou pela parede.
	Function CelulaVazia(x_, y_: integer): boolean;
		Var retorno: boolean;
		Begin
			retorno:=TRUE;
			for i:=1 to Tamanho do
			begin
				if ((x_=X[i]) and (y_=Y[i])) then	// Se a célula está sendo ocupada pela cobra
				begin
					retorno:=FALSE;
					break;
				end;
			end;
			if retorno	// Se a célula NÃO está sendo ocupada pela cobra...
			and ((x_=0) or (x_=Largura+1) or (y_=0) or (y_=Altura+1))	// mas está em uma parede
				then retorno:=FALSE;
			if retorno then	// Se a célula não está ocupada pela cobra, nem na parede...
			begin
				for i:=1 to QtdObstaculos do
				begin
					if ((x_=ObstaculoX[i]) and (y_=ObstaculoY[i])) then	// mas está ocupada por um obstáculo
					begin
						retorno:=FALSE;
						break;
					end; 
				end;
			end;
			CelulaVazia:=retorno;
		End;

	//------------------------------------------------------------------------------------------------------------------------------
	//	Procedure DesenharPonto: Desenha um ponto em uma
	//	posição aleatória do grid, caso essa posição esteja vazia
	Procedure DesenharPonto;
		Begin
			randomize;	// Ligar o gerador de números randômicos
			repeat
				PontoX:=random(Largura)+1;	// ...
				PontoY:=random(Altura)+1;	// Gerar coordenadas aleatórias...
			until (CelulaVazia(PontoX,PontoY));	// até que o ponto gerado esteja vazio
			textcolor(green);
			DesenharCelula(PontoX,PontoY,#219);
			gotoxy(1,1);
		End;
	//------------------------------------------------------------------------------------------------------------------------------
	Procedure Mover;
		Begin
			if PegouPonto then
			begin
				Tamanho:=Tamanho+1;
				PegouPonto:=FALSE;
			end;
			if ((X[Tamanho]>0) and (Y[Tamanho]>0)) then
			begin
				textcolor(green);
				DesenharCelula(X[Tamanho],Y[Tamanho],#177);	// Apagando o rabo
			end;
			i:=X[1];
			X[1]:=X[1]+SentidoHorizontal;
			for k:=2 to Tamanho do
			begin
				j:=X[k];
				X[k]:=i;
				i:=j;
			end;
			i:=Y[1];
			Y[1]:=Y[1]+SentidoVertical;
			for k:=2 to Tamanho do
			begin
				j:=Y[k];
				Y[k]:=i;
				i:=j;
			end;
			textcolor(black);
			DesenharCelula(X[1],Y[1],#219);	// Desenhando a cabeça
			TempoRestante:=tempo;
			gotoxy(1,1);
		End;
	//------------------------------------------------------------------------------------------------------------------------------
	//	Function Colidiu: Retorna TRUE se a cobra entrou em colisão com a parede ou com, próprio corpo ou com um obstáculo
	Function Colidiu: boolean;
		Var retorno: boolean;
		Begin
			retorno:=FALSE;
			for i:=2 to Tamanho do
			begin
				if ((X[1]=X[i]) and (Y[1]=Y[i])) then	// Se a cobra colidiu com o próprio corpo
				begin
					retorno:=TRUE;
					break;
				end;
			end;
			if not retorno	// Se a cobra não colidiu com o próprio corpo
			and ((X[1]=0) or (X[1]=Largura+1) or (Y[1]=0) or (Y[1]=Altura+1))	// mas colidiu com a parede
				then retorno:=TRUE;
			if not retorno then	// Se a cobra não colidiu com o próprio corpo, nem com a parede
			begin
				for i:=1 to QtdObstaculos do
				begin
					if ((X[1]=ObstaculoX[i]) and (Y[1]=ObstaculoY[i])) then	// Se a cobra colidiu com um obstáculo
					begin
						retorno:=TRUE;
						break;
					end; 
				end;
			end;
			Colidiu:=retorno;
		End;
	//------------------------------------------------------------------------------------------------------------------------------
	//	Procedure Inverter: Caso a cobra esteja andando em um determinado sentido e o usuário a direcione
	//	para o sentido oposto ocorreria que a cobra se moveria por cima do próprio corpo. Para que isso
	//	não aconteça esta procedure faz com que a cobra inverta todas as suas partes
	//	(a cabeça se torna o rabo e o rabo se torna a cabeça)
	Procedure Inverter;
		Begin
			SentidoHorizontal:=X[Tamanho]-X[(Tamanho-1)];	// Determinar o novo sentido com base no posicionamento...
			SentidoVertical:=Y[Tamanho]-Y[(Tamanho-1)];	// das duas últimas partes da cobra
			for i:=0 to ((Tamanho div 2)-1) do
			begin
				j:=X[(Tamanho-i)];
				X[(Tamanho-i)]:=X[(1+i)];
				X[(1+i)]:=j;
				j:=Y[(Tamanho-i)];
				Y[(Tamanho-i)]:=Y[(1+i)];
				Y[(1+i)]:=j;
			end;
			TempoRestante:=tempo;
		End;
	//-----------------------------------------------------------------------------------
	//	Desenhar os obstáculos
	Procedure DesenharObstaculos;
		Var PontoVazio: boolean;	// Se for FALSE significa que o ponto está sendo ocupado pela cobra ou por um obstáculo
		Begin
			randomize;	// Ligar o gerador de números randômicos
			for i:=1 to QtdObstaculos do
			begin
				repeat
					ObstaculoX[i]:=random(Largura)+1;	// ...
					ObstaculoY[i]:=random(Altura)+1;	// Gerar coordenadas aleatórias
					PontoVazio:=TRUE;
					for j:=1 to Tamanho do
					begin
						if ((ObstaculoX[i]=X[j]) and (ObstaculoY[i]=Y[j])) then
						begin	// Se a célula está sendo ocupada pela cobra
							PontoVazio:=FALSE;
							break;
						end;
					end;
					if (PontoVazio and (i>1)) then	// Se o ponto ainda é considerado vazio
					begin
						for j:=1 to (i-1) do
						begin
							if ((ObstaculoX[i]=ObstaculoX[j]) and (ObstaculoY[i]=ObstaculoY[j])) then
							begin	// mas a célula está sendo ocupada por outro obstáculo definido anteriormente
								PontoVazio:=FALSE;
								break;
							end;
						end;
					end;
					if (PontoVazio and (ObstaculoX[i]=X[1])) then
						PontoVazio:=FALSE;
				until (PontoVazio);	// Gerar coordenadas aleatórias até que o ponto gerado esteja vazio
				textcolor(red);
				DesenharCelula(ObstaculoX[i],ObstaculoY[i],#219);
			end;
			gotoxy(1,1);
		End;
	//------------------------------------------------------------------------------------------------------------------------------
	Procedure ObjetivoInteligente;
		Var DistHor, DistVert: integer;
		Function Modulo(a: integer): integer;
			Begin
				if (a>=0) then Modulo:=a
				else Modulo:=(-1)*a;
			End;
		Begin
			textcolor(green);
			DesenharCelula(PontoX,PontoY,#177);	// Apagando o ponto
			DistHor:=PontoX-X[1];
			DistVert:=PontoY-Y[1];
			//-----------------------------------------------------------
			//	Fugir horizontalmente
			if (Modulo(DistHor)<Modulo(DistVert)) then
			begin
				if (PontoX<X[1])
				and (CelulaVazia((PontoX-1),(PontoY))) then
					PontoX:=PontoX-1;	// Fugir para a esquerda
				
				if (PontoX>X[1])
				and (CelulaVazia((PontoX+1),(PontoY))) then
					PontoX:=PontoX+1;	// Fugir para a direita
				
				if (PontoX=X[1]) then
				begin
					if (random(2)=0) and (CelulaVazia((PontoX-1),(PontoY))) then
						PontoX:=PontoX-1	// Fugir para a esquerda
					else
					begin
						if (CelulaVazia((PontoX+1),(PontoY))) then
							PontoX:=PontoX+1	// Fugir para a direita
						else
						begin
							//-----------------------------------------------------
							//	Fugir verticalmente
							if (PontoY<Y[1])
							and (PontoY>1)
							and (CelulaVazia((PontoX),(PontoY-1))) then
							begin
								PontoY:=PontoY-1;	// Fugir para cima
							end;
							
							if (PontoY>Y[1])
							and (PontoY<Altura)
							and (CelulaVazia((PontoX),(PontoY+1))) then
							begin
								PontoY:=PontoY+1;	// Fugir para baixo
							end;
						end;
					end;
				end;
			end;
			//-----------------------------------------------------------
			//	Fugir verticalmente
			if (Modulo(DistHor)>Modulo(DistVert)) then
			begin
				if (PontoY<Y[1])
				and (PontoY>1)
				and (CelulaVazia((PontoX),(PontoY-1))) then
				begin
					PontoY:=PontoY-1;	// Fugir para cima
				end;
				
				if (PontoY>Y[1])
				and (PontoY<Altura)
				and (CelulaVazia((PontoX),(PontoY+1))) then
				begin
					PontoY:=PontoY+1;	// Fugir para baixo
				end;
				
				if (PontoY=Y[1]) then
				begin
					if (random(2)=0) and (CelulaVazia((PontoX),(PontoY-1))) then
						PontoY:=PontoY-1	// Fugir para cima
					else
					begin
						if (CelulaVazia((PontoX),(PontoY+1))) then
							PontoY:=PontoY+1	// Fugir para baixo
						else
						begin
							//-----------------------------------------------------
							//	Fugir horizontalmente
							if (random(2)=0) then
							begin
								if (PontoX<X[1])
								and (CelulaVazia((PontoX-1),(PontoY))) then
									PontoX:=PontoX-1;	// Fugir para a esquerda
								
								if (PontoX>X[1])
								and (CelulaVazia((PontoX+1),(PontoY))) then
									PontoX:=PontoX+1;	// Fugir para a direita
							end;
						end;
					end;
				end;
			end;
			//-----------------------------------------------------------
			//	Decisão aleatória (Distâncias iguais)
			if (Modulo(DistHor)=Modulo(DistVert)) then
			begin
				//-----------------------------------------------------
				//	Fugir horizontalmente
				if (random(2)=0) then
				begin
					if (PontoX<X[1])
					and (CelulaVazia((PontoX-1),(PontoY))) then
						PontoX:=PontoX-1;	// Fugir para a esquerda
					
					if (PontoX>X[1])
					and (CelulaVazia((PontoX+1),(PontoY))) then
						PontoX:=PontoX+1;	// Fugir para a direita
					
					if (PontoX=X[1]) then
					begin
						if (random(2)=0)
						and (CelulaVazia((PontoX-1),(PontoY))) then
							PontoX:=PontoX-1	// Fugir para a esquerda
						else if (CelulaVazia((PontoX+1),(PontoY))) then
							PontoX:=PontoX+1;	// Fugir para a direita
					end;
				end
				//-----------------------------------------------------
				//	Fugir verticalmente
				else
				begin
					if (PontoY<Y[1])
					and (PontoY>1)
					and (CelulaVazia((PontoX),(PontoY-1))) then
					begin
						PontoY:=PontoY-1;	// Fugir para cima
					end;
					
					if (PontoY>Y[1])
					and (PontoY<Altura)
					and (CelulaVazia((PontoX),(PontoY+1))) then
					begin
						PontoY:=PontoY+1;	// Fugir para baixo
					end;
					
					if (PontoY=Y[1]) then
					begin
						if (random(2)=0)
						and (CelulaVazia((PontoX),(PontoY-1))) then
							PontoY:=PontoY-1	// Fugir para cima
						else if (CelulaVazia((PontoX),(PontoY+1))) then
							PontoY:=PontoY+1;	// Fugir para baixo
					end;
				end;
			end;
			
			textcolor(lightblue);
			DesenharCelula(PontoX,PontoY,#219);	// Desenhando o ponto na nova posição
		End;

	//---------------------------------------------------------------------------------
	//	INÍCIO DO PROGRAMA PRINCIPAL
	Begin
		textbackground(white);
		clrscr;
		
		//----------------------------------------------------------------------------
		//	Desenhar a área interna da grade
		textcolor(green);
		for i:=1 to Largura do
		begin
			For j:=1 to Altura do
				DesenharCelula(i,j,#177);
		end;
		//----------------------------------------------------------------------------
		//	Desenhar as paredes
		textcolor(red);
		for i:=0 to Largura+1 do
		begin
			DesenharCelula(i,0,#219);	// Desenhando parede superior
			DesenharCelula(i,Altura+1,#219);	// Desenhando parede inferior
		end;
		for i:=0 to Altura+1 do
		begin
			DesenharCelula(0,i,#219);	// Desenhando parede esquerda
			DesenharCelula(Largura+1,i,#219);	// Desenhando parede direita
		end;
		//-----------------------------------------------------------------------------------
		Tamanho:=3;	// Definição do tamanho inicial da cobra
		//-----------------------------------------------------------------------------------
		//	Coordenadas iniciais da cobra
		X[1]:=Largura div 2;	Y[1]:=Altura;
		for i:=2 to Tamanho do
		begin
			X[i]:=X[i-1]+1;	Y[i]:=Altura;
		end;
		//-----------------------------------------------------------------------------------
		//	Sentido inicial do movimento da cobra
		SentidoHorizontal:=0;	// Sem movimento horizontal
		SentidoVertical:=-1;	// Iniciar andando para cima
		//-----------------------------------------------------------------------------------
		tempo:=10;
		TempoRestante:=tempo;
		//-----------------------------------------------------------------------------------
		//	Desenhando a cobra em sua posição inicial
		textcolor(black);
		for i:=1 to Tamanho do
			DesenharCelula(X[i],Y[i],#219);
		gotoxy(1,1);
		//-----------------------------------------------------------------------------------
		DesenharObstaculos;
		//-----------------------------------------------------------------------------------
		PegouPonto:=FALSE;
		//-----------------------------------------------------------------------------------
		DesenharPonto;
		//-----------------------------------------------------------------------------------
		//	Início da repetição principal
		Repeat
			delay(1000 div pps);	// Suspendendo a execução do programa durante (1000 div pps) milisegundos
			//-------------------------------------------------------------------------------------------------
			tecla:='z';	// Esvaziando a variável
			//-------------------------------------------------------------------------------------------------
			//	Leitura das teclas	(no máximo uma tecla por passo)
			while keypressed do	// Foi usado WHILE DO, e não IF THEN, por que apenas a última tecla pressionada... 
				tecla:=readkey;	// enquanto a execução esteve suspensa será atribuída à variável TECLA
			//-------------------------------------------------------------------------------------------------
			//	Comandos do usuário
			case tecla of
				#72: begin	// Seta para cima
						if (SentidoVertical=1) then
							Inverter
						else
						begin
							SentidoHorizontal:=0;
							SentidoVertical:=-1;
							Mover;
						end;
					end;
				#80: begin	// Seta para baixo
						if (SentidoVertical=-1) then
							Inverter
						else
						begin
							SentidoHorizontal:=0;
							SentidoVertical:=1;
							Mover;
						end;
					end;
				#75: begin	// Seta para esquerda
						if (SentidoHorizontal=1) then
							Inverter
						else
						begin
							SentidoHorizontal:=-1;
							SentidoVertical:=0;
							Mover;
						end;
					end;
				#77: begin	// Seta para direita
						if (SentidoHorizontal=-1) then
							Inverter
						else
						begin
							SentidoHorizontal:=1;
							SentidoVertical:=0;
							Mover;
						end;
					end;
				#27:	begin	// ESC (Sair)
						break;
					end;
				#32: begin	// Espaço (Pausa)
						repeat
							if (readkey=#32) then
								break;
						until(FALSE);
					end;
			end;
			//-------------------------------------------------------------------------------------------------
			TempoRestante:=TempoRestante-1;	// Contagem regressiva para o próximo movimento
			if (TempoRestante=0) then
				Mover;
			//-------------------------------------------------------------------------------------------------
			if Colidiu then	// Se a cobra colidiu com o próprio corpo ou com a parede
				break;
			//-------------------------------------------------------------------------------------------------
			//	Pegando o objetivo
			if ((X[1]=PontoX) and (Y[1]=PontoY)) then
			begin
				if (Tamanho=TamanhoMaximo) then
					break
				else
					PegouPonto:=TRUE;	WRITE(#7);
				DesenharPonto;	// Desenhar um novo ponto na grade
				if ((tempo>1) and ((Tamanho mod 3)=0)) then
					tempo:=tempo-1;
			end;
			
			ObjetivoInteligente;
			
			//---------------------------------------------------------------------------------------------------------------
			//	PAINEL DE CONTROLE
			{TEXTCOLOR(LIGHTRED);
			GOTOXY(60,3);	WRITE('PAINEL DE CONTROLE');
			GOTOXY(60,5);	WRITE('Tamanho: ',Tamanho);
			GOTOXY(60,7);	WRITE('OBJ(X,Y): (',PontoX,', ',PontoY,')');
			GOTOXY(60,9);	WRITE('(X[1],Y[1]): (',X[1],', ',Y[1],')');
			GOTOXY(60,11);	WRITE('TEMPO^(-1): ',((1/tempo)*100):2:0);}
			GOTOXY(1,1);
		//---------------------------------------------------------------------------------------------------------------
		//	Final do PASSO
		Until (false);	// Loop infinito
	gotoxy(15,12);
	write('Pressione ENTER para sair...');
End.
