=head
Copyright (c) 2014 Dennis Hoppe
www.dennis-hoppe.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=cut
package RunnerDB;

use strict;
use warnings;

use DBI;

sub new {
    my $class = shift;
    my ($dbh) = @_;
    my $self = {};
    $self->{dbh} = $dbh;
    return bless($self, $class);
}

sub getRunsByUserId {
    my $self = shift;
    my ($User) = @_;
    my $UserId = $User->id;

    my $Statement = <<"END_SQL";
SELECT r.alias, r.id, r.distanceMeters
FROM Run as r
WHERE r.userId = ?;
END_SQL

    my $sth = $self->{dbh}->prepare($Statement);
    $sth->execute($UserId)
      or die "Can't connect to the database: $DBI::errstr\n";

    my @Result;
    while (my @row = $sth->fetchrow_array()) {
        my ($Alias, $Id, $DistanceMeters ) = @row;
        push @Result, {
            'Alias' => $Alias,
            'RunId' => $Id,
            'Distance' => $DistanceMeters
        };
    }
    $sth->finish();

    return \@Result;
}

=MySQL

-- -----------------------------------------------------
-- Table `runner`.`User`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `runner`.`User` (
  `alias` VARCHAR(255) NULL ,
  `id` INT NOT NULL ,
  `birthdate` DATE NULL ,
  `totalDistanceMeters` DOUBLE NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `runner`.`Run`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `runner`.`Run` (
  `alias` VARCHAR(255) NULL ,
  `id` INT NOT NULL ,
  `distanceMeters` DOUBLE NULL ,
  `userId` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `userId_idx` (`userId` ASC) ,
  CONSTRAINT `userId`
    FOREIGN KEY (`userId` )
    REFERENCES `runner`.`User` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

=cut

1;
