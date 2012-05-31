/* 
 * black heuristic
 */
eval(black,Board, Value):-
    count_pieces(black, Board, BlackPieces, WhitePieces),
    HeuristicValue1 is BlackPieces - WhitePieces,
	getCorners(Corners),
	getXSquares(XSquares),
	positionCount(black,Board,Corners,BlackCorner,WhiteCorner),
	positionCount(black,Board,XSquares,BlackXSquares,WhiteXSquares),
	CornersBonus is 10*(BlackCorner-WhiteCorner),
	XSquaresBonus is -10*(BlackXSquares-WhiteXSquares),
	Bonus is CornersBonus+XSquaresBonus,
	Value is HeuristicValue1+Bonus.

final(black,Board, Value):-
    full_board(Board),
    count_pieces(black, Board, BlackPieces, WhitePieces),
    Value is BlackPieces - WhitePieces.

/*count pieces at special position*/
positionCount(Color,Board,PositionList,Count,RivalCount):-
	positionCount(Color,Board,PositionList,0,0,Count,RivalCount).

positionCount(Color,Board,PositionList,CountBuf,RivalCountBuf,Count,RivalCount):-
	rival_color(Color,RivalColor),
	(
		PositionList=[]->
			Count=CountBuf,
			RivalCount=RivalCountBuf
		;
		PositionList = [Position|PositionsRest],
		Position = [Rowi,Coli|CheckList],
		(
			CheckList\=[]->
				CheckList=[CheckRow,CheckCol],
				piece(Board,CheckRow,CheckCol,CheckPiece)
			;
				CheckPiece=null
		),
		piece(Board,Rowi,Coli,Piece),
		(
			(Piece=Color,CheckPiece\=Color)->
				NCountBuf is CountBuf+1,
				NRivalCountBuf is RivalCountBuf
			;
			(Piece=RivalColor,CheckPiece\=RivalColor)->
				NCountBuf is CountBuf,
				NRivalCountBuf is RivalCountBuf +1
			;
				NCountBuf is CountBuf,
				NRivalCountBuf is RivalCountBuf
		),
		positionCount(Color,Board,PositionsRest,NCountBuf,NRivalCountBuf,Count,RivalCount)
	).


getCorners(Corners):-
	getRowCol(RR,CC),
	R is RR-1,
	C is CC-1,
	Corners=[[0,0],[0,C],
			 [R,0],[R,C]].
    
getXSquares(XSquares):-
	getRowCol(RR,CC),
	CornerR is RR-1,
	CornerC is CC-1,
	R is RR-2,
	C is CC-2,
	XSquares=[	[1,1, 0,0],
				[1,C, 0,CornerC],
			 	[R,1, CornerR,0],
				[R,C, CornerR,CornerC]
			].

/* 
 * white heuristic
 */
getCornerSquares(CornerSquares):-
    getRowCol(Rowi,Coli),
    R1 is Rowi-1,
    R2 is Rowi-2,
    C1 is Coli-1,
    C2 is Coli-2,
    CornerSquares= [[0,0,   0,1,    1,0,    1,1   ],
                    [R1,0,  R1,1,   R2,0,   R2,1  ],
                    [0,C1,  0,C2,   1,C1,   1,C2  ],
                    [R1,C1, R1,C2,  R2,C1,  R2, C2]].
    
 
eval(white,Board, Value):-
    count_pieces(black, Board, BlackPieces, WhitePieces),
    PieceValue is (BlackPieces - WhitePieces),!,
    valid_positions(Board, black, BlackValidMoves),
    valid_positions(Board, white, WhiteValidMoves),
    MobilityValue is (BlackValidMoves - WhiteValidMoves),!,
    getCornerSquares(CornerSquares),
    getCornerValue(Board, CornerSquares, CornerValue),!,
    Value is (10* PieceValue + 12* MobilityValue + 15* CornerValue).

final(white,Board, Value):-
    valid_positions(Board, black, BlackValidMoves),
    BlackValidMoves is 0,!,
    valid_positions(Board, white, WhiteValidMoves),
    WhiteValidMoves is 0,!,
    count_pieces(black, Board, BlackPieces, WhitePieces),
    Value is 20*(BlackPieces - WhitePieces),!.

getCornerValue(Board, CornerSquares, CornerValue):-
    getCornerValue(Board, CornerSquares, CornerValue, 0).
    
getCornerValue(Board, CornerSquares, CornerValue, CornerValueBuf):-
    /*writef('Corner %w %w %w\n', [CornerValue, CornerSquares, CornerValueBuf]),*/
    (
        CornerSquares = [] ->
            CornerValue is CornerValueBuf
        ;
		CornerSquares = [CurrentSqure|CornerSquaresRest],
		CurrentSqure = [CornerR, CornerC|CurrentSqureR1],
		CurrentSqureR1 = [CornerR1, CornerC1|CurrentSqureR2],
		CurrentSqureR2 = [CornerR2, CornerC2|CurrentSqureR3],
		CurrentSqureR3 = [CornerR3, CornerC3],
		piece(Board, CornerR, CornerC, PieceCorner),
		piece(Board, CornerR1, CornerC1, PieceCorner1),
		piece(Board, CornerR2, CornerC2, PieceCorner2),
		piece(Board, CornerR3, CornerC3, PieceCorner3),
		(
		    PieceCorner = empty ->
		    (
		        (PieceCorner1=black; PieceCorner2=black; PieceCorner3=black)->
		            Value = -1
		        ;
		        (PieceCorner1=white; PieceCorner2=white; PieceCorner3=white)->
		            Value = 1
		        ;
		            Value = 0
		    )
		    ;
		    PieceCorner = white ->
		        Value = -2
		    ;
		        Value = 2
		),
		/*writef('getCornerValue %w %w\n',[CurrentSqure, PieceCorner]),*/
		NCornerValueBuf is CornerValueBuf + Value,
		getCornerValue(Board, CornerSquaresRest, CornerValue, NCornerValueBuf)
    ).