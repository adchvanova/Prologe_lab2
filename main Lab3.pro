implement main
    open core, stdio, file

domains
    topics = news; economy; fashion.
    money = integer*.
    publicationD = publicationD(string PName, real Money, string Name).

class facts - publicationDb
    subscriber : (integer Ids, string Name, integer Age, string Adress).
    publication : (integer IDp, string PName, real Money).
    subscribed_to_publication : (integer IDp, integer Ids, string StartDay, integer Month).
    topics_of_publication : (integer IDp, topics Topic).

class facts
    s : (integer Ssum) single.

clauses
    s(0).

class predicates
    sum_el : (real* List) -> real Sum.
    amount_of_cost : () -> real Sum.
    max : (real* List, real Max [out]) nondeterm.
    %  max_cost : () -> real Max determ.
    min : (real* List, real Min [out]) nondeterm.
    % min_cost : () -> real Min determ.

clauses
    sum_el([]) = 0.
    sum_el([H | T]) = sum_el(T) + H.

class predicates
    all_subscribers : (integer IDp, integer Ids, string Name, integer Age, string Adress) -> main::publicationDb* All_subscriber nondeterm anyflow.
    all_subscribers_without_list : (integer IDp, integer Ids, string Name, integer Age, string Adress) nondeterm anyflow.
    sales_for_all_time : (integer IDp, real Sum, integer Ids) nondeterm anyflow.
    all_publication_of_a_specific_topic : (integer IDp, topics Topic, string Name) -> main::publicationDb* All_publication nondeterm anyflow.
    price_increase_by_10perset : (integer IDp, string PName, real Money, real NewMoney) nondeterm anyflow.
    indexof : (integer, money, integer [out]).
    indexof1 : (integer, money, integer, integer [out]).
    list_print : (main::publicationDb*) nondeterm.
    list : (main::publicationDb*) nondeterm.
    average_cost : () -> real Average determ.
    max_cost : () -> real Max determ.
    min_cost : () -> real Min determ.

clauses
    /* Кто является подписчиком издания*/
    all_subscribers_without_list(IDp, Ids, Name, Age, Adress) :-
        subscribed_to_publication(IDp, Ids, _, _Month),
        subscriber(Ids, Name, Age, Adress).

    all_subscribers(IDp, Ids, Name, Age, Adress) = All_subscriber :-
        subscribed_to_publication(IDp, Ids, _, _Month),
        subscriber(Ids, Name, Age, Adress),
        All_subscriber = [ subscriber(Ids, Name, Age, Adress) || subscriber(Ids, Name, Age, Adress) ].

    /* Кто сколько заплатил за журналы за все время его подписки*/
    sales_for_all_time(Publication, Sum, IDp) :-
        subscribed_to_publication(Publication, IDp, _, Month),
        publication(Publication, _, Money),
        Sum = Month * Money.

    /* Какая тема у изданий/ Поиск всех изданий заданной темы*/
    all_publication_of_a_specific_topic(IDp, Topic, Name) = All_publication :-
        publication(IDp, Name, _),
        topics_of_publication(IDp, Topic),
        All_publication = [ publication(IDp, Name, Money) || publication(IDp, Name, Money) ].
    list([H | T]) :-
        write(H),
        nl,
        list(T).

    /* Увеличение цены на 10 процентов*/
    price_increase_by_10perset(IDp, PName, Money, NewMoney) :-
        publication(IDp, PName, Money),
        NewMoney = Money * 110 / 100.

    indexof(X, L, N) :-
        indexof1(X, L, 1, N).
    indexof1(_, [], _, -1) :-
        !.
    indexof1(X, [X | _], N, N) :-
        !.
    indexof1(X, [_ | T], K, N) :-
        indexof1(X, T, K + 1, N).

    max([Max], Max). %если список состоит только из одного элемента
    max([X1, X2 | T], Max) :-
        X1 >= X2,
        max([X1 | T], Max).
    max([X1, X2 | T], Max) :-
        X1 <= X2,
        max([X2 | T], Max).

    max_cost() = MaxCost :-
        max([ Money || publication(_, PName, Money) ], Max),
        MaxCost = Max,
        !.

    min([Min], Min). %если список состоит только из одного элемента
    min([X1, X2 | T], Min) :-
        X1 <= X2,
        min([X1 | T], Min).
    min([X1, X2 | T], Min) :-
        X1 >= X2,
        min([X2 | T], Min).

    min_cost() = MinCost :-
        min([ Money || publication(_, PName, Money) ], Min),
        MinCost = Min,
        !.

    amount_of_cost() = Sum :-
        Sum = sum_el([ Money || publication(_, _, Money) ]).

    average_cost() = Average :-
        Average = amount_of_cost() / 6,
        !.

    list_print([H | T]) :-
        write(H),
        nl,
        list_print(T).

clauses
    run() :-
        console::init(),
        reconsult("../database.txt", publicationDb),
        fail.
    run() :-
        all_subscribers_without_list(IDp, Ids, Name, Age, _Adress),
        stdio::write("Name and age of user publication with ", IDp, " ID: ", Name, " ", Age, "\n"),
        fail.
    run() :-
        sales_for_all_time(IDp, Sum, IDp),
        stdio::write("sales_for_all_time : ", Sum, "\n"),
        fail.
    run() :-
        price_increase_by_10perset(IDp, PName, Money, NewMoney),
        stdio::write("Old price of ", PName, " is ", Money, ". New price is ", NewMoney, "\n"),
        fail.
    run() :-
        write("All publication of a specific topic (write topic news or economy or fashion:) \n"),
        write("Topic is "),
        X = stdio::read(),
        List = all_publication_of_a_specific_topic(_, X, Name),
        list(List),
        nl,
        fail.
    run() :-
        write("The maximum cost of publication: ", [ PName || publication(_, PName, max_cost()) ], " = ", max_cost(), "$ \n"),
        write("The minimum cost of publication: ", [ PName || publication(_, PName, min_cost()) ], " = ", min_cost(), "$ \n"),
        write("The average cost of publication: = ", average_cost(), "$ \n"),
        nl,
        write("Output a list of all subcribers \n"),
        List2 = all_subscribers(IDp, Ids, Name, Age, Adress),
        list(List2),
        fail.
    run() :-
        stdio::write("End test\n").

end implement main

goal
    console::runUtf8(main::run).
