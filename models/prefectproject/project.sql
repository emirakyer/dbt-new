{{config(
    materialized="incremental",
    incremental_strategy="insert_overwrite",
    unique_key="song_name",
    partition_by={
        "field":"release_year",
        "data_type":"int64",
        "range":{
            "start":0,
            "end":2024,
            "interval":20
        }
    },
    cluser_by=["artistsname"],
)}}

-- Common Table Expression (CTE) named 'data'
WITH data AS (
    SELECT *
    FROM {{ source('staging', 'spotify') }}
    where trackname is not null AND artistsname is not null
)

-- Main SELECT statement using the 'data' CTE
SELECT 
    CAST(trackname AS STRING) AS song_name,
    CAST(artistsname AS STRING) AS singer,           
    CAST(artistcount AS INTEGER) AS artist_quantity,           
    CAST(releasedyear AS INTEGER) AS release_year,          
    --CAST(releasedmonth AS INTEGER) AS release_month,         
    CAST(releasedday AS INTEGER) AS release_day, 
    CAST(inspotifyplaylists AS INTEGER) AS on_spotify_playlists,
    CAST(inspotifycharts AS INTEGER) AS on_spotify_charts,       
    CAST(streams AS INTEGER) AS total_streams,               
    CAST(inappleplaylists AS INTEGER) AS on_apple_playlists,      
    CAST(inapplecharts AS INTEGER) AS on_apple_charts,         
    CAST(indeezerplaylists AS INTEGER) AS on_deezer_playlists,     
    CAST(indeezercharts AS INTEGER) AS on_deezer_charts,        
    CAST(inshazamcharts AS INTEGER) AS on_shazam_charts,       
    CAST(bpm AS INTEGER) AS bpm,                   
    CAST("key" AS STRING) AS track_key,                  
    CAST(mode AS STRING) AS track_mode,                  
    CAST(danceability AS INTEGER) AS danceability_percentage,          
    CAST(valence AS INTEGER) AS valence_percentage,               
    CAST(energy AS INTEGER) AS energy_percentage,                
    CAST(acousticness AS INTEGER) AS acousticness_percentage,          
    CAST(instrumentalness AS INTEGER) AS instrumentalness_percentage,      
    CAST(liveness AS INTEGER) AS liveness_percentage,              
    CAST(speechiness AS INTEGER) AS speechiness_percentage,
    {{ get_month_name('releasedmonth') }} as release_month,   
    from data
{% if is_incremental() %}
-- this filter will only be applied on an incremental run
where releasedyear > (select max(release_year) from {{ this }})
{% endif %}