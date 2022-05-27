/*
====================================================================================================================================================
====================================================================================================================================================
=====================================Top 100 Greatest Metal Albums of All Time======================================================================
====================================================================================================================================================
====================================================================================================================================================

SUMMARY
In June 2017, Rolling Stone magazine released their all-encompassing list of the greatest metal albums of all-time. 
This dataset can be found here: https://data.world/kcmillersean/rs-100-greatest-metal-albums-of-all-time and it was shared by Sean Miller
I separated some of the data into tables for easier manipulation with SQL and I hope to see some of the bands I listen to here.
*/


--Which year had the most awesome metal album releases?
SELECT
	ma.ReleaseYear
	, COUNT(ma.Album) AS total_albums
FROM metal_album ma
GROUP BY ma.ReleaseYear
ORDER BY total_albums DESC
;

--Answer: Based on our current dataset, 1992 was the most metal year with nice and awesome metal albums. What albums and bands were the ones that were released in 1992?
/*NOTE: The approach below aims to consider that the dataset might change and the year with more metal releases might change. The script will detect 
that year automatically. I use rank instead of Limit 1 in case that the total of releases is equal for more than one year */
SELECT
	a.Artist
	, ma.ReleaseYear
	, ma.Album
	, ma.AlbumID_Rank as Ranking_in_top_100_albums
	, rank() OVER (ORDER BY ma.AlbumID_Rank) as Ranking_in_the_year
FROM metal_album ma
LEFT JOIN --Use left since there are some missing artist ids
	artists a ON a.id = ma.artist_id
WHERE ReleaseYear IN (
	SELECT ReleaseYear FROM (
		SELECT
			ma.ReleaseYear
			, COUNT(ma.Album) AS total_albums
			, RANK () OVER (ORDER BY COUNT(ma.Album) DESC) ValRank 
		FROM metal_album ma
		GROUP BY ma.ReleaseYear
		ORDER BY total_albums DESC
	)
	WHERE ValRank = 1
) ORDER BY ma.AlbumID_Rank
;

--Answer: Vulgar Display of Power by Pantera has the position number 10 in the top 100 metal albums and it has the highest rank in 1992. 
--I personally don't really like Pantera but that's what data says lol regarding 1992. Ok, let us see what the ratings say, then. 
--Maybe I can see a band I really like haha in this dataset. 
SELECT
	a.Artist
	, ma.Album
	, ma.ReleaseYear
FROM metal_album ma
LEFT JOIN --Use left since there are some missing artist ids
	artists a ON a.id = ma.artist_id
WHERE ma.Rating = 5
ORDER BY ma.ReleaseYear
;

--Ok... I am so glad to see the Black Sabbath album and the Master of Puppets in the 5 rating evaluation. These albums are quite awesome. 
-- Well... I can see that some artists had more than one album evaluated with 5 stars. Let us see whose artists are.
SELECT
	a.Artist
FROM metal_album ma
LEFT JOIN --Use left since there are some missing artist ids
	artists a ON a.id = ma.artist_id
WHERE ma.Rating = 5
GROUP BY a.Artist
HAVING COUNT(ma.Album) > 1 
;
--Ok... Black Sabbath was the only band in this dataset that appears as the one that has released more than one album with 5 stars. 
--Let us talk about genres as I am a big fan of Nu, Gothic, Symphonic, Black and Death Metal. Let us see if there are some of my fav albums/artists in our top 100 dataset:
SELECT
	a.Artist
	, ma.Album
	, ma.AlbumID_Rank
	, g.SubMetalGenre
FROM metal_album ma
LEFT JOIN --Use left since there are some missing artist ids
	artists a ON a.id = ma.artist_id
INNER JOIN genres g ON ma.SubMetalGenreid = g.id
WHERE g.SubMetalGenre IN (
	'Black Metal'
	, 'Death Metal'
	, 'Gothic Metal'
	, 'Nu Metal'
)
ORDER BY ma.AlbumID_Rank
;

/*It is nice to see Mayhem and Darkthrone in the list. Those were some of the most influential bands in the 2nd black metal wave created in Norway. 
Regarding the Nu Metal, it is nice to see System of a Down, Korn and Slipknot (Iowa is my fav album from them). I don't really like the Death and Gothic metal 
albums that appeared in this list but it is what it is. Let us see how many top 100 metal albums from my fav genres have been released by year of release:*/
WITH base AS (
	SELECT
		a.Artist
		, ma.Album
		, ma.ReleaseYear
		, g.SubMetalGenre
	FROM metal_album ma
	LEFT JOIN --Use left since there are some missing artist ids
		artists a ON a.id = ma.artist_id
	INNER JOIN genres g ON ma.SubMetalGenreid = g.id
	WHERE g.SubMetalGenre IN (
		'Black Metal'
		, 'Death Metal'
		, 'Gothic Metal'
		, 'Nu Metal'
	)
)
SELECT 
	b.ReleaseYear
	, SUM(CASE WHEN b.SubMetalGenre = 'Black Metal' THEN 1 ELSE 0 END) AS black_metal
	, SUM(CASE WHEN b.SubMetalGenre = 'Death Metal' THEN 1 ELSE 0 END) AS death_metal
	, SUM(CASE WHEN b.SubMetalGenre = 'Gothic Metal' THEN 1 ELSE 0 END) AS gothic_metal
	, SUM(CASE WHEN b.SubMetalGenre = 'Nu Metal' THEN 1 ELSE 0 END) AS nu_metal
	
	, SUM(CASE WHEN b.SubMetalGenre = 'Black Metal' THEN 1 ELSE 0 END) 
	+ SUM(CASE WHEN b.SubMetalGenre = 'Death Metal' THEN 1 ELSE 0 END) 
	+ SUM(CASE WHEN b.SubMetalGenre = 'Gothic Metal' THEN 1 ELSE 0 END)
	+ SUM(CASE WHEN b.SubMetalGenre = 'Nu Metal' THEN 1 ELSE 0 END)as total_releases
	FROM base b
GROUP BY b.ReleaseYear
ORDER BY total_releases DESC
;

/*1993 was a good year for Death and Gothic metal indeed. The reason behind that no Black Metal releases appear might have to do with some unfortunate 
incidents that happened in Norway and Sweden.
2001 was a nice year in terms of the nu metal releases. 2001 and years around saw Linkin Park, Korn, S.O.A.D and others do some nice stuff.  

Anyway, this is my analysis I did on this tables with SQL. Hope you enjoyed my comments on this and see my SQL skills and a bit of my knowledge about
metal music haha. \m/  */