final(Board, Value):-
    full_board(Board),
    count_pieces(black, Board, BlackPieces, WhitePieces),
    Value is BlackPieces - WhitePieces.

eval(Caller,Board, Value):-
    count_pieces(black, Board, BlackPieces, WhitePieces),
    HeuristicValue1 is BlackPieces - WhitePieces,
	getCorners(Corners),
	positionCount(black,Board,Corners,BlackCorner,WhiteCorner),
	Bonus is 10*(BlackCorner-WhiteCorner),
/*
    valid_positions(Board, black, BlackValidMoves),
    valid_positions(Board, white, WhiteValidMoves),
    HeuristicValue2 is BlackValidMoves - WhiteValidMoves,
    max_list([HeuristicValue1,HeuristicValue2], Value).
*/
	Value is HeuristicValue1+Bonus.


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
		nth0(0,Position,Rowi),
		nth0(1,Position,Coli),
		piece(Board,Rowi,Coli,Piece),
		(
			Piece=Color->
				NCountBuf is CountBuf+1,
				NRivalCountBuf is RivalCountBuf
			;
			Piece=RivalColor->
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
	R is RR-2,
	C is CC-2,
	XSquares=[[1,1],[1,C],
			 [R,1],[R,C]].

