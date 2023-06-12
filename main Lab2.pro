% Copyright

implement main
    open core, stdio, file

domains
    topics = news; economy; fashion.

class facts - publicationDb
    subscriber : (integer Ids, string Name, integer Age, string Adress).
    publication : (integer IDp, string PName, integer Money).
    subscribed_to_publication : (integer IDp, integer Ids, string StartDay, integer Month).
    topics_of_publication : (integer IDp, topics Topic).

class facts
    s : (integer Ssum) single.

clauses
    s(0).

class predicates
    /*budget_summary : () failure anyflow.*/
    all_subscribers : (integer IDp, integer Ids, string Name, integer Age, string Adress) nondeterm anyflow.
    sales_for_all_time : (integer IDp, integer Sum, integer Ids) nondeterm anyflow.
    all_publication_of_a_specific_topic : (integer IDp, topics Topic, string Name) nondeterm anyflow.
    price_increase_by_10perset : (integer IDp, string PName, integer Money, real NewMoney) nondeterm anyflow.

clauses
    /* Кто является подписчиком издания*/
    all_subscribers(IDp, Ids, Name, Age, Adress) :-
        subscribed_to_publication(IDp, Ids, _, _Month),
        subscriber(Ids, Name, Age, Adress).

    /* Кто сколько заплатил за журналы за все время его подписки*/
    sales_for_all_time(Publication, Sum, IDp) :-
        subscribed_to_publication(Publication, IDp, _, Month),
        publication(Publication, _, Money),
        Sum = Month * Money.

    /* Какая тема у изданий/ Поиск всех изданий заданной темы*/
    all_publication_of_a_specific_topic(IDp, Topic, Name) :-
        publication(IDp, Name, _),
        topics_of_publication(IDp, Topic).

    /* Увеличение цены на 10 процентов*/
    price_increase_by_10perset(IDp, PName, Money, NewMoney) :-
        publication(IDp, PName, Money),
        NewMoney = Money * 110 / 100.

clauses
    run() :-
        console::init(),
        reconsult("../database.txt", publicationDb),
        fail.
    run() :-
        all_publication_of_a_specific_topic(IDp, Topic, Name),
        stdio::write("topic of publication ", Name, " is ", Topic, "\n"),
        fail.

    run() :-
        all_subscribers(IDp, Ids, Name, Age, _Adress),
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
        stdio::write("End test\n").

end implement main

goal
    console::runUtf8(main::run).
