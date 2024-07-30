


library(leaflet)
library(terra)
library(RColorBrewer)

LSOA <- sf::st_read("C:/Users/samantha.yeo/OneDrive - The Nature Conservancy/Documents/Projects/BEF/ActionMapper/PathwayData/MasterSnap/geoBoundaries/admin/geoBoundaries_cgaz_nb_adm2.shp" )
LSOA <- LSOA %>% dplyr::filter(adm0_id %in% c('AGO', 'CMR', 'CAF', 'COG', 'COD', 'GAB', 'GNQ'))

# look at data
names(LSOA)

LSOABins <- c(100, 500, 1000, 3000, 5000, 10000, 30000, 50000, 300000, 100000, 3000000, 500000, 1000000, 3000000, 5000000) # 87,573,519
LSOAPal <- colorBin('YlGnBu', domain = LSOA$area_ha, bins = LSOABins)

# create information to include in the popup
LSOA$popup <- paste("<strong>",LSOA$ncs_name,"</strong>", "</br>", 
                    LSOA$adm0_id, "</br>",
                    "Area (ha):", prettyNum(LSOA$area_ha, big.mark = ","))

# create color palette for the var you want
LSOAPal <- colorQuantile(palette = "YlGnBu", LSOA$area_ha, n = 7)
LSOAPal <- colorNumeric(
  palette = "YlGnBu",
  domain = LSOA$area_ha)

m = leaflet() %>%   
  # add in options for basemap
  addProviderTiles(providers$Esri.WorldImagery, group = "Basemap - aerial") %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Basemap - greyscale") %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group = "Basemap - dark") %>%
  # add in a "zoom to world" button
  addEasyButton(easyButton(
    icon = "fa-globe", title = "Zoom to Level 1", onClick = JS("function(btn, map){ map.setZoom(1); }"))) %>%
  # add in a cross hairs (not working?)
  addEasyButton(easyButton(
    icon = "fa-crosshairs", title = "Locate Me", onClick = JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
  # Add a tile layer from a known map provider
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolygons(
    data = LSOA,
    stroke = TRUE,
    weight = .2,
    color = "#ABABAB",
    smoothFactor = .3,
    opacity = .9,
    fillColor = ~LSOAPal(area_ha),
    fillOpacity = .8,

    # Create a pop up banner for each polygon, highlight area
    popup = ~popup,
    highlightOptions = highlightOptions(
      color = "#000000",
      weight = 1.5,
      bringToFront = TRUE,
      fillOpacity = 0.5
    )
  ) %>%
  # add legend
      addLegend("bottomright",opacity = 1,
      colors = c("#ffffcc","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#0c2c84"),
      title = "Area (ha)",
      labels = c("<100,000","300,000","500,000","1,000,000","1,300,000", "3,000,000", "5,000,000")
      ) %>%
  # add layer controls for basemaps ### THESE DON'T WORK???
      addLayersControl(
      overlayGroups = c("Area (ha)", "Stations"),
      baseGroups = c("Basemap - dark","Basemap - greyscale","Basemap - aerial"),
      options = layersControlOptions(collapsed = T) # F to force view the options
      )
m


