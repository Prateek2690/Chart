# Chart

## PLOTTING DETAILS (AS FROM PYTHON)------------------------------------------------------------------------------------------

 p = plotting.figure(width=900, height=600,x_axis_type='datetime')
            
            p.title = "OAS vs Govt"
            p.title_text_color = "black"
            p.title_text_font = "arial"
            p.title_text_font_size = "10pt"
        
            p.title_text_font_style = "bold"      
            
            
           # p.xaxis.axis_label = "Source: BAML/CreditSights"
            #p.xaxis.axis_label = "Source:BofA / ML Index data, CreditSights                                                                                                    "
            
            #p.xaxis.axis_label.title_text_font = "arial"
            #p.xaxis.axis_label.title_text_font_size = "7pt"
            
            #p.xaxis.axis_label.text_align = 'left'
            

            p.ygrid.grid_line_alpha = 12
            p.ygrid.grid_line_dash = [5, 4]
            p.xgrid.grid_line_color = None
            #p.axis.minor_tick_in = 1
            p.yaxis.major_tick_in = 1
            p.yaxis.major_tick_line_width = 1
            p.xaxis.axis_line_color = "black"
            p.yaxis[0].formatter = NumeralTickFormatter(format="0")
            
            p.yaxis.minor_tick_line_color = None
            p.xaxis.axis_label_text_font_size = "8pt"
            p.xaxis.major_label_text_color = "black"
            p.yaxis.major_label_text_color = "black"
            p.xaxis[0].formatter = DatetimeTickFormatter(formats=dict(
                                    hours=["%b %y"],
                                    days=["%d %b"],
                                    months=["%b %y"],
                                    years=["%b %y"],
                                )
                            )
                            
            p.line(x, y,legend=shows, line_width=2.5,color='#50728b')
          
            p.line(x, z,legend=shows_B,line_width=2.5,color='#ffa60c')
         
            # show the results
            p.legend.orientation = legend_pos
            p.legend.border_line_color = "white"
            p.legend.label_text_font = "arial"
            
            show(p)
            
  END-------------------------------------------------------------------------------------------------------------------------
