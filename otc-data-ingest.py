#
# Read flight on-time data using generic data ingest python program
#
import pandas as pd


def csv_read():
    import csv
    with open('../data/On_Time_Reporting_2018_5.csv', 'r') as csvFile:
        reader = csv.reader(csvFile)
        prelim_row_count = 0
        for row in reader:
            prelim_row_count = prelim_row_count + 1

    print('csv_read total number of rows including header')
    print(prelim_row_count)
    return


def pandas_read():
    df = pd.read_csv('../data/On_Time_Reporting_2018_5.csv', sep=',')

    print(df.columns)
    print(df.index)
    print(df.dtypes)
    print(df.head(5))
    print(df.tail(5))

    print('Describe Dataframe')
    print(df.describe)

    print('Null Row Count')
    print(df.isnull().sum())

    print('Pandas read column counts')
    print(df.count())
    return df


def pandas_deep_copy(df):
    ddf = df.copy(deep=True)
    return ddf


def pandas_write_csv(dcf):
    dcf.to_csv('../data/otc-flight-data.csv', sep=',')
    print('Pandas write column counts')
    print(dcf.count())
    return


def pandas_write_snappy(dcf):
    dcf.to_parquet('../data/spr_otc-flight-data.parquet', compression = 'snappy')
    return


def main():

    csv_read()

    df = pandas_read()

    ddf = pandas_deep_copy(df)

    pandas_write_csv(ddf)

    pandas_write_snappy(ddf)


if __name__ == "__main__":

    print('start process')

    main()

    print('end process')
