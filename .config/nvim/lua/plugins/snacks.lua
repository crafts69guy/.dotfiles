return {
	{
		"folke/snacks.nvim",
		opts = {
			scroll = { enabled = false },

			input = { enabled = true },

			statuscolumn = { enabled = true },

			dashboard = {
				preset = {
					header = [[
            dddddddd                                                                                                                
            d::::::d                                                                                                                
            d::::::d                                                                                                                
            d::::::d                                                                                                                
            d:::::d                                                                                                                 
    ddddddddd:::::d     eeeeeeeeeeee  vvvvvvv           vvvvvvv           ggggggggg   ggggguuuuuu    uuuuuuyyyyyyy           yyyyyyy
  dd::::::::::::::d   ee::::::::::::ee v:::::v         v:::::v           g:::::::::ggg::::gu::::u    u::::u y:::::y         y:::::y 
 d::::::::::::::::d  e::::::eeeee:::::eev:::::v       v:::::v           g:::::::::::::::::gu::::u    u::::u  y:::::y       y:::::y  
d:::::::ddddd:::::d e::::::e     e:::::e v:::::v     v:::::v           g::::::ggggg::::::ggu::::u    u::::u   y:::::y     y:::::y   
d::::::d    d:::::d e:::::::eeeee::::::e  v:::::v   v:::::v            g:::::g     g:::::g u::::u    u::::u    y:::::y   y:::::y    
d:::::d     d:::::d e:::::::::::::::::e    v:::::v v:::::v             g:::::g     g:::::g u::::u    u::::u     y:::::y y:::::y     
d:::::d     d:::::d e::::::eeeeeeeeeee      v:::::v:::::v              g:::::g     g:::::g u::::u    u::::u      y:::::y:::::y      
d:::::d     d:::::d e:::::::e                v:::::::::v               g::::::g    g:::::g u:::::uuuu:::::u       y:::::::::y       
d::::::ddddd::::::dde::::::::e                v:::::::v                g:::::::ggggg:::::g u:::::::::::::::uu      y:::::::y        
 d:::::::::::::::::d e::::::::eeeeeeee         v:::::v          ......  g::::::::::::::::g  u:::::::::::::::u       y:::::y         
  d:::::::::ddd::::d  ee:::::::::::::e          v:::v           .::::.   gg::::::::::::::g   uu::::::::uu:::u      y:::::y          
   ddddddddd   ddddd    eeeeeeeeeeeeee           vvv            ......     gggggggg::::::g     uuuuuuuu  uuuu     y:::::y           
                                                                                   g:::::g                       y:::::y            
                                                                       gggggg      g:::::g                      y:::::y             
                                                                       g:::::gg   gg:::::g                     y:::::y              
                                                                        g::::::ggg:::::::g                    y:::::y               
                                                                         gg:::::::::::::g                    yyyyyyy                
                                                                           ggg::::::ggg                                             
                                                                              gggggg                                                
          ]],
				},
				highlight = {
					header = "DashboardHeader",
				},
			},
		},
	},
}
