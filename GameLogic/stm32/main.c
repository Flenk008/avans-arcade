/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2023 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdbool.h>
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
SPI_HandleTypeDef hspi1;

TIM_HandleTypeDef htim3;

/* USER CODE BEGIN PV */

static int8_t buttonDPAD[] = {0,0,0,0}; //1left 2right 3down 4up

struct playerData{
	uint16_t posX;
	uint16_t posY;
	uint8_t radius;
	uint8_t rotation; //45 degrees steps 0 == right 2 == down 4 == left 6 == up
	uint8_t directionX; //direction where its looking at in case no input;
	int8_t speed;	//10 default L/R MODifier
	bool inAir;

};

struct playerData player1;

uint8_t tileMap[30][40] =
  {
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0,0,0,0,0,0 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 },
		  {1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 ,1,1,1,1,1,1,1,1,1,1 }



  };

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_SPI1_Init(void);
static void MX_TIM3_Init(void);
/* USER CODE BEGIN PFP */
void buttonRead();
void playerMovement();
void sendData(uint8_t, uint16_t);
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */


/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_SPI1_Init();
  MX_TIM3_Init();
  /* USER CODE BEGIN 2 */
  // correct byte for led control
  uint16_t pos_x; //0b0000 0001 0011 0110
  uint16_t pos_y;

  uint8_t left = 0;
  uint8_t right = 0;
  uint8_t up = 0;
  uint8_t down = 0;



  uint8_t pos_x_bit[2];
  uint8_t pos_y_bit[2];
  uint8_t data_send[3];

  int tileX;
  int tileY;
//  struct playerData player1;
 //int buttons[] = {GPIO_PIN_4,GPIO_PIN_5,GPIO_PIN_6,GPIO_PIN_8}; // 1 left // 2 right // 3 up // 4 down

/// init struct
  player1.posX = 31000; //0b0000 0001 0011 0110
  player1.posY = 21000;
  player1.radius = 8;
  player1.speed = 1;
  player1.directionX = 1;
  player1.rotation = 8;
  player1.inAir = false;
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {




		buttonRead();
		playerMovement();


		// send data via SPI //adjust map size
		pos_x = player1.posX / 100;
		pos_y = player1.posY / 100;

		sendData(0b01000000,pos_x);
		sendData(0b00000000,pos_y);


    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief SPI1 Initialization Function
  * @param None
  * @retval None
  */
static void MX_SPI1_Init(void)
{

  /* USER CODE BEGIN SPI1_Init 0 */

  /* USER CODE END SPI1_Init 0 */

  /* USER CODE BEGIN SPI1_Init 1 */

  /* USER CODE END SPI1_Init 1 */
  /* SPI1 parameter configuration*/
  hspi1.Instance = SPI1;
  hspi1.Init.Mode = SPI_MODE_MASTER;
  hspi1.Init.Direction = SPI_DIRECTION_1LINE;
  hspi1.Init.DataSize = SPI_DATASIZE_8BIT;
  hspi1.Init.CLKPolarity = SPI_POLARITY_LOW;
  hspi1.Init.CLKPhase = SPI_PHASE_1EDGE;
  hspi1.Init.NSS = SPI_NSS_SOFT;
  hspi1.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_16;
  hspi1.Init.FirstBit = SPI_FIRSTBIT_MSB;
  hspi1.Init.TIMode = SPI_TIMODE_DISABLE;
  hspi1.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
  hspi1.Init.CRCPolynomial = 7;
  hspi1.Init.CRCLength = SPI_CRC_LENGTH_DATASIZE;
  hspi1.Init.NSSPMode = SPI_NSS_PULSE_DISABLE;
  if (HAL_SPI_Init(&hspi1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SPI1_Init 2 */

  /* USER CODE END SPI1_Init 2 */

}

/**
  * @brief TIM3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM3_Init(void)
{

  /* USER CODE BEGIN TIM3_Init 0 */

  /* USER CODE END TIM3_Init 0 */

  TIM_ClockConfigTypeDef sClockSourceConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};

  /* USER CODE BEGIN TIM3_Init 1 */

  /* USER CODE END TIM3_Init 1 */
  htim3.Instance = TIM3;
  htim3.Init.Prescaler = 7999;
  htim3.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim3.Init.Period = 65535;
  htim3.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim3.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  if (HAL_TIM_Base_Init(&htim3) != HAL_OK)
  {
    Error_Handler();
  }
  sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
  if (HAL_TIM_ConfigClockSource(&htim3, &sClockSourceConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim3, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM3_Init 2 */

  /* USER CODE END TIM3_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9, GPIO_PIN_SET);

  /*Configure GPIO pin : PA9 */
  GPIO_InitStruct.Pin = GPIO_PIN_9;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : PB4 PB5 PB6 PB8 */
  GPIO_InitStruct.Pin = GPIO_PIN_4|GPIO_PIN_5|GPIO_PIN_6|GPIO_PIN_8;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */
void sendData(uint8_t address, uint16_t data)
{
			uint8_t bitData[3];
			bitData[2] = data & 0xff;
			bitData[1] = (data >> 8);
			bitData[0] = address; // first byte is address



			HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9, GPIO_PIN_RESET);
			HAL_SPI_Transmit(&hspi1, bitData, 3, 100); //2*8 bit data
			HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9, GPIO_PIN_SET);

}


/*
#define GPIO_PIN_0                 ((uint16_t)0x0001U)   Pin 0 selected
#define GPIO_PIN_1                 ((uint16_t)0x0002U)   Pin 1 selected
#define GPIO_PIN_2                 ((uint16_t)0x0004U)   Pin 2 selected
#define GPIO_PIN_3                 ((uint16_t)0x0008U)   Pin 3 selected
#define GPIO_PIN_4                 ((uint16_t)0x0010U)   Pin 4 selected
#define GPIO_PIN_5                 ((uint16_t)0x0020U)   Pin 5 selected
#define GPIO_PIN_6                 ((uint16_t)0x0040U)   Pin 6 selected
#define GPIO_PIN_7                 ((uint16_t)0x0080U)   Pin 7 selected
#define GPIO_PIN_8                 ((uint16_t)0x0100U)   Pin 8 selected
#define GPIO_PIN_9                 ((uint16_t)0x0200U)   Pin 9 selected
#define GPIO_PIN_10                ((uint16_t)0x0400U)   Pin 10 selected
#define GPIO_PIN_11                ((uint16_t)0x0800U)   Pin 11 selected
#define GPIO_PIN_12                ((uint16_t)0x1000U)   Pin 12 selected
#define GPIO_PIN_13                ((uint16_t)0x2000U)   Pin 13 selected
#define GPIO_PIN_14                ((uint16_t)0x4000U)   Pin 14 selected
#define GPIO_PIN_15                ((uint16_t)0x8000U)   Pin 15 selected
#define GPIO_PIN_All               ((uint16_t)0xFFFFU)   All pins selected
*/

void buttonRead()
{
	//int buttons[] = {GPIO_PIN_4,GPIO_PIN_5,GPIO_PIN_6,GPIO_PIN_8}; // 1 left // 2 right // 3 down // 4 up  8-6-4-5
	uint16_t buttons[] = {0x0100U,0x0040U,0x0010U,0x0020U}; // 1 left // 2 right // 3 down // 4 up

	for(int i = 0; i < 4; i++)
	{
		if(HAL_GPIO_ReadPin(GPIOB, buttons[i]) == 1)
		{
			if((i+2) % 2 == 0)
			{
				buttonDPAD[i] = 1;
			}
			else
			{
				buttonDPAD[i] = -1;
			}
		}
		else
		{
			buttonDPAD[i] = 0;
		}
	}
}

void playerMovement()
{

	int8_t directionX = 0; // -1 = L || 1 == R
	int8_t directionY = 0; // -1 = D || 1 == U

	uint8_t i,j;
	uint8_t rotation = 0; // 0-7
	//temp var for testing



	// direction calc
	directionX = buttonDPAD[0] + buttonDPAD[1];
	directionY = buttonDPAD[2] + buttonDPAD[3];

	//rotation calc
	for(i = -1; i < 2;i++)
	{
		for(j = -1; j < 2; j++)
		{
			if(directionX == i)
			{
				if(directionY == j)
				{
					if(i != 0 && j != 0) //dont update when player idle
					{
						player1.rotation = rotation;
					}
				}
			}
		rotation++;
		}
	}
	//direction calc
	if(directionX != 0) //update direction if player is not idle
	{
		player1.directionX = directionX;
	}
	//collision map x-axis

	//tile calc including radius and direction for background coliision

	uint16_t tileColX;
	uint16_t tileColY = ( player1.posY / 100) / 16; ;

	// remaining space between grid and exact
	uint8_t modTileX;
	uint8_t modTileY;



	if(player1.inAir == false && directionX != 0)
	{
		if(directionX == 1)
		{
			tileColX = ( ( player1.posX / 100) + player1.radius ) / 20;
			modTileX = ( player1.posX + ( 100 * player1.radius ) ) % 2000;
		}
		else if(directionX == -1)
		{
			tileColX = ( ( player1.posX / 100) - player1.radius ) / 20;
			modTileX = ( player1.posX - ( 100 * player1.radius ) ) % 2000;
		}

			if(tileMap[tileColY][tileColX + directionX] != 1)
			{
				player1.posX = player1.posX + (directionX * player1.speed); // NEW x set
			}

			else if(tileMap[tileColY][tileColX + directionX] == 1)
			{
				if(modTileX < player1.speed)
				{
					player1.posX = player1.posX + (directionX * modTileX); // NEW x set
				}
				else
				{
					player1.posX = player1.posX + (directionX * player1.speed); // NEW x set
				}
			}

	}
	else //if in air different all borders have to be checked
	{

	}

	//collision map floor (y-axis) (falling)
	// if falling no jump press (implement)
	/*
	tileColY = (( player1.posY / 100) + player1.radius) / 16; //bottom of player box
	modTileY = 1;
	if(tileMap[tileColY+1][tileColX] != 1) //rework after jumping
	{
		player1.posY = player1.posY + 5 ;// NEW y set //makew var gravity
		//playerStat = falling; //for later use of graphics/sound
	}
	*/
	//else if(tileMap[])





}
/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
