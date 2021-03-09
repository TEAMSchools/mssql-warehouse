USE [gabby]
GO

/****** Object:  Table [utilities].[cache_view_queue]    Script Date: 8/22/2017 12:38:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [utilities].[cache_view_queue](
	[schema_name] [nvarchar](max) NULL,
	[view_name] [nvarchar](max) NULL,
	[timestamp] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


