# Errors in the notebooks

## NBA Analysis

### Version A
```python
nba = nba.assign(
    Height = pd.to_numeric(nba['Height'].str.replace('cm','').str.replace('-[0-9]*','')),
    Weight = pd.to_numeric(nba['Weight'].str.replace('kg',''))
)
```
* Error: Just `pd.to_numeric` is used, instead of accounting for the unit conversions. Class: Data

---

* After the `Unique Players` section of markdown the dataset is not narrowed down to the unique players
* Error: Does not narrow down to unique players. Class: Data

---

```python
conditions = [
    nba['Position'].str.contains('G'),
    True
]

choices = [
    'Guard',
    'Forward'
]

nba = nba.assign(
    Position_GF = np.select(conditions, choices)
)
```
* Error: This misidentifies "F-G" and "GF" as guards. Class: Coding/Data

---

```python
heights = (ggplot(nba, aes(x = 'Position_GF', y = 'Height'))`
          + geom_col()
          + xlab('Position'))

weights = (ggplot(nba, aes(x = 'Position_GF', y = 'Weight'))
          + geom_col()
          + xlab('Position')) 

We find that while Forwards weigh more than Guards, Guards are taller than Forwards.
```
* Error:  Column plot heights are the sum of all values. Class: Coding

---

```python
my_test = ttest_ind(
    x1 = nba[(nba['Position'] == 'PG')]['Height'],
    x2 = nba[(nba['Position'] == 'SG')]['Height'],
    alternative = 'smaller'
)
t_stat = my_test[0]
p_value = my_test[1]
deg_free = my_test[2]
print("We obtain a t statistic of {t_stat}. This yields a p-value of {p_value}.".format(t_stat = deg_free, p_value = p_value))
```
* Error: Should be 2-sided test, using data to form hypotheses is bad! Class: Stats
* Error: deg_free is used in the print statement rather than t_stat. Class Coding/Stats

---

### Version B

```python
nba.groupby('Player').agg(
    Height=('Height', 'median'),
    Weight=('Weight', 'median'),
    Position=('Position', 'first')
)
```
* Error: `nba` dataset isn't actually updated. Class: Coding

---

```python
heights = (ggplot(nba, aes(x = 'Position_GF', y = 'Height'))
          + geom_boxplot()
          + xlab('Position'))

weights = (ggplot(nba, aes(x = 'Position_GF', y = 'Weight'))
          + geom_boxplot()
          + xlab('Position'))
```

`It appears from the plots that the Forwards in the dataset have a mean height of about 81 inches, while Guards have a mean height of 75.3 inches.`

* Error: median not mean from a boxplot. Class: Stats

---

```python
my_test = ttest_ind(`
    x1 = nba[(nba['Position'] == 'PG')]['Height'],
    x2 = nba[(nba['Position'] == 'SG')]['Height'],
    alternative = 'two-sided'
)
t_stat = my_test[0]
p_value = my_test[1]
deg_free = my_test[2]
print("We obtain a t statistic of {t_stat}. This yields a p-value of {p_value}.".format(t_stat = deg_free, p_value = p_value))
```
`We fail to reject the null hypothesis, and find that there is no detectable height difference between Point Guards and Shooting Guards.`
* Error: Should be rejecting, not failing to reject! Class: Stats
* Error: deg_free used in print statement instead of t_stat. Class: Coding/Stats

---

### Version C
* This version contains no errors.

## Elections Analysis
### Version A
```python
data.groupby('precinct').size()
```
* Error: Does not count the number of precincts by province, only counts the number of precincts. Class: Coding

---

```python
len(data.query('emptyBallots < invalidBallots'))
```
* Error: Does not account for what municipalities have more invalid ballots then empty ballots. Class: Coding

---

```python
data.query('ballotsLeader < registeredVoters')
```
* Error: Does not define the majority, simply checks which rows have more registered voters than votes for the leader. Class: Coding

---

```python
data['municipality'].str.replace('ñ', 'n')
```
* Error: Doesn't reassign data['municipality']. Class: Coding/Data

---

```python
grouped = data.assign(
    pct_leader = data['ballotsLeader']/data['validBallots']
).groupby('community')

for name, group in grouped:
    group = group.assign(
        mean_pct_leader = lambda x: mean(x['pct_leader']),
        sd_pct_leader = lambda x: stdev(x['pct_leader']),
        up_pct_leader = lambda x: x['mean_pct_leader']+2*x['sd_pct_leader']
    )
    display(group.query('pct_leader > up_pct_leader')[0:5])
```
* Error: Uses a slice to display the first five entries rather than the top 5 entries. Class: Coding/Data

---

```python
chart = (ggplot(data, aes(x = 'community', y = 'registeredVoters'))
          + geom_boxplot()
          + xlab('Position'))
display(chart)
```
* Error: Box plot is not useful here to visualize the total number of registeredVoters. Class: Stats

---

```python
chart = (ggplot(data.assign(pct_leader = data['ballotsLeader']/data['validBallots'])
                , aes(x = 'pct_leader', y = 'community', color = 'community'))
        + geom_line())

display(chart)
```
* Error: Line chart is not applicable for seeing a distribution, should use a histogram. Class: Stats

---

```python
model = sm.ols(
    formula="ballotsLeader ~ province", 
    data=data[data['community'] == 'GALICIA']
).fit()
model.summary()
```
`There was no association at all found between any of the provinces and the number of votes.`
* Error: No association is found when there should be an association between provinces and the number of vote. Class: Stats

---

```python
chart = (ggplot(data.assign(pct_leader = data['ballotsLeader']/data['validBallots'],
                           pct_voted = (data['validBallots'] + data['invalidBallots'])/data['registeredVoters'])
                , aes(x = 'validBallots', y = 'pct_leader', color = 'community'))
        + geom_point(alpha= 0.5)
        + geom_smooth(method = 'loess', color = 'blue'))

display(chart)
```
* Error: Regression does not use the percentage of voters, it uses the number of valid ballots. Class: Stats/Coding

---

```python
chart = (ggplot(data, aes(x = 'registeredVoters', y = 'invalidBallots', color = 'community'))
        + geom_point(alpha= 0.5)
        + stat_smooth(color = 'blue'))

display(chart)
```
* Error: Regression poorly fits the data and does not query the data for registeredVoters < 50000. Class: Stats/Coding.

---

### Version B
```python
data.groupby('province')['precinct'].value_counts()
```
* Error: value_counts gives counts the unique values, we simply want the number of precincts by province. Class: Coding

---

```python
len(data.query('emptyBallots > invalidBallots')['municipality'].unique())
```
* Error: Gives the number of municipalities which have more empty ballots than invalid ballots

---

```python
data.query('ballotsLeader > registeredVoters')
```
* Error: Doesn't assign majority column and returns an empty DF. Class: Coding

---

```python
data['municipality'].str.replace('ñ','n')
```
* Error: Doesn't reassign data['municipality']. Class: Coding/Data

---

```python
grouped = data.assign(
    pct_leader=data['ballotsLeader']/data['validBallots'],
    mean_pct_leader = lambda x: mean(x['pct_leader']),
    sd_pct_leader = lambda x: stdev(x['pct_leader']),
    up_pct_leader = lambda x: x['mean_pct_leader']+2*x['sd_pct_leader']
).query(
    'pct_leader > up_pct_leader'
).groupby('community')

for name,group in grouped:
    display(group.nlargest(5, "pct_leader"))
```
* Error: The groupby is performed after the query, this gives incorrect results in the up_pct_leader column. Class: Coding/Data

---

```python
chart = (ggplot(data, aes(x = 'community'))
          + geom_bar())
display(chart)
```
* Error: Y value of the bar chart is the count of communities, this is not what we want. Class: Coding.

---

```python
chart = (ggplot(data, aes(x = 'ballotsLeader', y = 'community', colour = 'community'))
        + geom_line())
display(chart)
```
* Error: Chart is a line chart, we want a histogram here to see the distribution. Class: Stats/Coding

---

```python
model = sm.ols(
    formula="ballotsLeader ~ province",
    data=data[data['community'] == 'GALICIA']).fit()
model.summary()
```
`We can only say that in Lugo there was an association between the province and the number of votes.`
* Error: Association only finds an effect in Lugo when there should be two other provinces which have an association. Class: Stats.

---

```python
chart = (ggplot(data.assign(pct_leader = data['ballotsLeader']/data['validBallots'],
                           pct_voted = data['validBallots']/data['registeredVoters'])
                , aes(x = 'pct_voted', y = 'pct_leader', color = 'community'))
        + geom_point(alpha= 0.5)
        + geom_smooth(method = 'lm', color = 'blue'))

display(chart)
```
* Error: pct_voted column doesn't account for the invalid ballots thus it's incorrect. Class: Coding.

---

```python
chart = (ggplot(data, aes(x = 'registeredVoters', y = 'invalidBallots', color = 'community'))
        + geom_point(alpha = 0.5)
        + geom_smooth(method = 'lm', color = 'blue'))
display(chart)
```
* Error: Chart doesn't query the data for registeredVoters < 50000. Class: Stats/Coding

---

### Version C
* This version contains no errors.